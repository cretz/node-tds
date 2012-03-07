{Socket} = require 'net'
fs = require 'fs'
util = require 'util'

{AttentionPacket} = require './attention.packet'
{BufferBuilder} = require './buffer-builder'
{BufferStream, StreamIndexOutOfBoundsError} = require './buffer-stream'
{ColMetaDataToken} = require './colmetadata.token'
{DoneToken} = require './done.token'
{Login7Packet} = require './login7.packet'
{LoginAckToken} = require './loginack.token'
{Packet} = require './packet'
{PreLoginPacket} = require './prelogin.packet'
{SqlBatchPacket} = require './sqlbatch.packet'
{TdsConstants} = require './tds-constants'
{TokenStreamPacket} = require './tokenstream.packet'

###*
Low level client for TDS access
###
class exports.TdsClient
  
  constructor: (@_handler) ->
    if not @_handler? then throw new Error 'Handler required'
    @logDebug = @logError = false
    @state = TdsConstants.statesByName['INITIAL']

  debug: (contents) ->
    if @logDebug
      if not @_debugFd?
        @_debugFd = fs.openSync 'debug.out', 'w'
      fs.writeSync @_debugFd, util.format.apply(null, arguments) + '\n'
    
  connect: (config) ->
    if @state isnt TdsConstants.statesByName['INITIAL']
      throw new Error 'Client must be in INITIAL state before connecting'
    @state = TdsConstants.statesByName['CONNECTING']
    @debug 'Connecting to SQL Server with config %j', config
    try
      @_preLoginConfig = config
      # create socket
      @_socket = new Socket()
      # attach listeners
      @_socket.on 'connect', @_socketConnect
      @_socket.on 'error', @_socketError
      @_socket.on 'data', @_socketData
      @_socket.on 'end', @_socketEnd
      @_socket.on 'close', @_socketClose
      # attempt connect
      @_socket.connect config.port ? 1433, config.host ? 'localhost'
    catch err
      if @logError then console.error 'Error connecting: ' + err
      @state = TdsConstants.statesByName['INITIAL']
      @_handler?.error? err
      @end()
    
  login: (config) ->
    if @state isnt TdsConstants.statesByName['CONNECTED']
      throw new Error 'Client must be in CONNECTED state before logging in'
    @state = TdsConstants.statesByName['LOGGING IN']
    @debug 'Logging in with config %j', config 
    try
      # create packet
      login = new Login7Packet
      for key, value of config
        login[key] = value
      @tdsVersion = config.tdsVersion ? TdsConstants.versionsByVersion['7.1.1']
      # send
      @_sendPacket login
    catch err
      if @logError then console.error 'Error on login: ', err
      @state = TdsConstants.statesByName['CONNECTED']
      @_handler.error? err
    
  sqlBatch: (sqlText) ->
    if @state isnt TdsConstants.statesByName['LOGGED IN']
      throw new Error 'Client must be in LOGGED IN state before executing sql'
    @debug 'Executing SQL Batch: %s', sqlText
    try
      # create packet
      sqlBatch = new SqlBatchPacket
      sqlBatch.sqlText = sqlText
      # send
      @_sendPacket sqlBatch
    catch err
      if @logError then console.error 'Error executing: ', err.stack
      @_handler?.error? err

  cancel: ->
    if @state isnt TdsConstants.statesByName['LOGGED IN']
      throw new Error 'Client must be in LOGGED IN state before cancelling'
    @debug 'Cancelling'
    try
      @cancelling = true
      @_sendPacket new AttentionPacket
    catch err
      @cancelling = undefined
      if @logError then console.error 'Error cancelling: ', err.stack
      @_handler?.error? err    
      
  _socketConnect: =>
    @debug 'Connection established, pre-login commencing'
    try
      # create new stream
      @_stream = new BufferStream
      # do prelogin
      prelogin = new PreLoginPacket
      for key, value of @_preLoginConfig
        if prelogin.hasOwnProperty key
          prelogin[key] = value
      @_sendPacket prelogin
    catch err
      if @logError then console.error 'Error on pre-login: ', err
      @state = TdsConstants.statesByName['INITIAL']
      @_handler?.error? err
      @end()
    
  _socketError: (error) =>
    if @logError then console.error 'Error in socket: ', error
    @_handler?.error? error
    @end()
    
  _socketData: (data) =>
    @debug 'Received %d bytes at state', data.length, @state, data
    @_stream.append data
    # do we have a token stream already?
    if @_tokenStream?
      @_handleToken()
    else
      @_handlePacket()
  
  _getPacketFromType: (type) ->
    switch type
      when TokenStreamPacket.type
        if @state is TdsConstants.statesByName['CONNECTING']
          new PreLoginPacket
        else
          new TokenStreamPacket
      when PreLoginPacket.type then new PreLoginPacket
      else throw new Error 'Unrecognized type: ' + type 
    
  _handleToken: ->
    token = null
    receivedLoginAck = false
    loop
      @_stream.beginTransaction()
      currentOffset = 0
      try
        currentOffset = @_stream.currentOffset()
        token = null
        if @_tokenStreamRemainingLength is 1
          # just ignore the type byte
          @_stream.skip 2
        else 
          token = @_tokenStream.nextToken @_stream, @
        # if our remaining length could be less than zero, we commit and hold on to the pending amount
        if @_tokenStreamRemainingLength - (@_stream.currentOffset() - currentOffset) < 0
          @debug 'From %d to %d left negative remaining', currentOffset, @_stream.currentOffset(),
            @_tokenStreamRemainingLength - (@_stream.currentOffset() - currentOffset)
          @debug 'Buffer at %d', currentOffset, @_stream.getBuffer().slice(currentOffset)
          # rollback
          @_stream.rollbackTransaction()
          # grab only the amount we could have gotten and store
          @_pendingTokenStreamBuffer = @_stream.readBuffer @_tokenStreamRemainingLength
          @debug 'Got pending buffer: ', @_pendingTokenStreamBuffer
          # commit that read
          @_stream.commitTransaction()
          @debug 'What is left: ', @_stream.getBuffer()
          # now try to get a packet again
          @_handlePacket()
          return
        else 
          @_pendingTokenStreamBuffer = null
        @_tokenStreamRemainingLength -= @_stream.currentOffset() - currentOffset
        @debug 'From %d to %d offset, remaining: ',
          currentOffset, @_stream.currentOffset(), @_tokenStreamRemainingLength
        @_stream.commitTransaction()
      catch err
        if err instanceof StreamIndexOutOfBoundsError
          @debug 'Stream incomplete, rolling back' 
          # rollback
          @_stream.rollbackTransaction()
          return
        else
          # possible someone read too far and needs to work with a packet again
          if @_tokenStreamRemainingLength - (@_stream.currentOffset() - currentOffset) < 0
            @debug 'Error happened when reading outside of range; ignoring...'
            # rollback
            @_stream.rollbackTransaction()
            # grab only the amount we could have gotten and store
            @_pendingTokenStreamBuffer = @_stream.readBuffer @_tokenStreamRemainingLength
            # commit that read
            @_stream.commitTransaction()
            # now try to get a packet again
            @_handlePacket()
            return
          else
            if @logError then console.error 'Error reading stream: ', err.stack 
            throw err
      if @_tokenStreamRemainingLength is 0
        @_tokenStream = @_tokenStreamRemainingLength = null
      if not @_cancelling or token.type is DoneToken.type
        @_cancelling = undefined
        # call handler if present
        @_handler?[token.handlerFunction]? token
        # handle my way
        @debug 'Checking token type: ', token.type
        switch token.type
          when LoginAckToken.type
            if @state isnt TdsConstants.statesByName['LOGGING IN']
              throw new Error 'Received login ack when not logging in'
            receivedLoginAck = true
          when ColMetaDataToken.type
            @colmetadata = token
      # break
      if not @_tokenStream? then break
    # fire login?
    if receivedLoginAck
      @state = TdsConstants.statesByName['LOGGED IN']
      @_handler?.login?()
    # more packet to be had?
    if @_stream.getBuffer().length > 0
      @debug 'More packet to be had, continuing...'
      @_handlePacket()

  _handlePacket: ->
    packet = null
    @_stream.beginTransaction()
    try
      # grab packet
      header = Packet.retrieveHeader @_stream, @
      # instantiate
      packet = @_getPacketFromType header.type
      # we stream token streams
      if packet instanceof TokenStreamPacket
        @debug 'Found token stream packet'
        @_tokenStream = packet
        @_tokenStreamRemainingLength = header.length - 8
      else
        @debug 'Found non token stream packet'
        # parse
        packet.fromBuffer @_stream, @
      # commit
      @_stream.commitTransaction()
      # did we have some pending?
      if @_pendingTokenStreamBuffer?
        @debug 'Appending previously held buffer: ', @_pendingTokenStreamBuffer
        @_stream.prepend @_pendingTokenStreamBuffer
        @_tokenStreamRemainingLength += @_pendingTokenStreamBuffer.length
        @_pendingTokenStreamBuffer = null
    catch err
      if err instanceof StreamIndexOutOfBoundsError
        @debug 'Stream incomplete, rolling back' 
        # rollback
        @_stream.rollbackTransaction()
        return
      else
        if @logError then console.error 'Error reading stream: ', err.stack 
        throw err
    if @_tokenStream?
      @_handleToken()
    else
      @debug 'Buffer remaining: ', @_stream.getBuffer()
      # handle packet
      if packet instanceof PreLoginPacket
        @state = TdsConstants.statesByName['CONNECTED']
        @_handler?.connect? packet
      else 
        if @logError then console.error 'Unrecognized type: ' + packet.type
        throw new Error 'Unrecognized type: ' + packet.type
    
  _socketEnd: =>
    @debug 'Socket ended remotely' 
    @_socket = null
    @state = TdsConstants.statesByName['INITIAL']
    @_handler?.end?()
  
  _socketClose: (had_error) =>
    @debug 'Socket closed' 
    @_socket = null
    @state = TdsConstants.statesByName['INITIAL']
    @_handler?.close? had_error
    
  _sendPacket: (packet) ->
    @debug 'Sending packet: %s at state', packet.name, @state
    builder = new BufferBuilder()
    builder = packet.toBuffer new BufferBuilder(), @
    buff = builder.toBuffer()
    @debug 'Packet size: %d', buff.length
    @_socket.write buff
    
  end: ->
    @debug 'Ending socket' 
    try
      @_socket.end()
    @_socket = null
    @state = TdsConstants.statesByName['INITIAL']
    @_handler?.end?()
