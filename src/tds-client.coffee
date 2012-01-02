{Socket} = require 'net'

{BufferBuilder} = require './buffer-builder'
{BufferStream, StreamIndexOutOfBoundsError} = require './buffer-stream'
{ColMetaDataToken} = require './colmetadata.token'
{Login7Packet} = require './login7.packet'
{LoginAckToken} = require './loginack.token'
{Packet} = require './packet'
{PreLoginPacket} = require './prelogin.packet'
{SqlBatchPacket} = require './sqlbatch.packet'
{TdsConstants} = require './tds-constants'
{TokenStreamPacket} = require './tokenstream.packet'

class exports.TdsClient
  
  constructor: (@_handler) ->
    if not @_handler? then throw new Error 'Handler required'
    @logDebug = @logError = false
    @state = TdsConstants.statesByName['INITIAL']
    
  connect: (config) ->
    if @state isnt TdsConstants.statesByName['INITIAL']
      throw new Error 'Client must be in INITIAL state before connecting'
    @state = TdsConstants.statesByName['CONNECTING']
    if @logDebug then console.log 'Connecting to SQL Server with config %j', config
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
    if @logDebug then console.log 'Logging in with config %j', config 
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
    if @logDebug then console.log 'Executing SQL Batch: %s', sqlText
    try
      # create packet
      sqlBatch = new SqlBatchPacket
      sqlBatch.sqlText = sqlText
      # send
      @_sendPacket sqlBatch
    catch err
      if @logError then console.error 'Error executing: ', err.stack
      @_handler?.error? err
      
  _socketConnect: =>
    if @logDebug then console.log 'Connection established, pre-login commencing'
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
    if @logDebug then console.log 'Received %d bytes at state', data.length, 
      @state, data
    @_stream.append data
    # do we have a token stream already?
    if @_tokenStream?
      @_handleTokenStream()
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
      try
        currentOffset = @_stream.currentOffset()
        token = @_tokenStream.nextToken @_stream, @
        @_tokenStreamRemainingLength -= @_stream.currentOffset() - currentOffset
        if @logDebug then console.log 'From %d to %d offset, remaining: ',
          currentOffset, @_stream.currentOffset(), @_tokenStreamRemainingLength
        @_stream.commitTransaction()
      catch err
        if err instanceof StreamIndexOutOfBoundsError
          if @logDebug then console.log 'Stream incomplete, rolling back' 
          # rollback
          @_stream.rollbackTransaction()
          return
        else
          if @logError then console.error 'Error reading stream: ', err.stack 
          throw err
      if @_tokenStreamRemainingLength is 0
        @_tokenStream = @_tokenStreamRemainingLength = null
      # call handler if present
      @_handler?[token.handlerFunction]? token
      # handle my way
      if @logDebug then console.log 'Checking token type: ', token.type
      switch token.type
        when LoginAckToken.type
          if @state isnt TdsConstants.statesByName['LOGGING IN']
            throw new Error 'Received login ack when not loggin in'
          receivedLoginAck = true
        when ColMetaDataToken.type
          @columns = token.columns
          @columnsByName = token.columnsByName
      # break
      if not @_tokenStream? then break
    # fire login?
    if receivedLoginAck
      @state = TdsConstants.statesByName['LOGGED IN']
      @_handler?.login?()

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
        if @logDebug then console.log 'Found token stream packet'
        @_tokenStream = packet
        @_tokenStreamRemainingLength = header.length - 8
      else
        if @logDebug then console.log 'Found non token stream packet'
        # parse
        packet.fromBuffer @_stream, @
      # commit
      @_stream.commitTransaction()
    catch err
      if err instanceof StreamIndexOutOfBoundsError
        if @logDebug then console.log 'Stream incomplete, rolling back' 
        # rollback
        @_stream.rollbackTransaction()
        return
      else
        if @logError then console.error 'Error reading stream: ', err.stack 
        throw err
    if @_tokenStream?
      @_handleToken()
    else
      if @logDebug then console.log 'Buffer remaining: ', @_stream.getBuffer()
      # handle packet
      if packet instanceof PreLoginPacket
        @state = TdsConstants.statesByName['CONNECTED']
        @_handler?.connect? packet
      else 
        if @logError then console.error 'Unrecognized type: ' + packet.type
        throw new Error 'Unrecognized type: ' + packet.type
    
  _socketEnd: =>
    if @logDebug then console.log 'Socket ended remotely' 
    @_socket = null
    @state = TdsConstants.statesByName['INITIAL']
    @_handler?.end?()
  
  _socketClose: =>
    if @logDebug then console.log 'Socket closed' 
    @_socket = null
    @state = TdsConstants.statesByName['INITIAL']
    
  _sendPacket: (packet) ->
    if @logDebug
      console.log 'Sending packet: %s at state', packet.name, @state
    builder = new BufferBuilder()
    builder = packet.toBuffer new BufferBuilder(), @
    buff = builder.toBuffer()
    if @logDebug then console.log 'Packet size: %d', buff.length
    @_socket.write buff
    
  end: ->
    if @logDebug then console.log 'Ending socket' 
    try
      @_socket.end()
    @_socket = null
    @state = TdsConstants.statesByName['INITIAL']
    @_handler?.end?()
