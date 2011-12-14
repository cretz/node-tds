{Socket} = require 'net'
# {EventEmitter} = require 'events'

{BufferBuilder} = require './buffer-builder'
{BufferStream, StreamIndexOutOfBoundsError} = require './buffer-stream'
{ColMetaDataPacket} = require './colmetadata.packet'
{DonePacket} = require './done.packet'
{ErrorMessagePacket} = require './error.message.packet'
{InfoMessagePacket} = require './info.message.packet'
{Login7Packet} = require './login7.packet'
{LoginAckPacket} = require './loginack.packet'
{Packet} = require './packet'
{PreLoginPacket} = require './prelogin.packet'
{RowPacket} = require './row.packet'
{SqlBatchPacket} = require './sqlbatch.packet'
{TdsConstants} = require './tds-constants'

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
      if @logError then console.error 'Error executing: ', err
      @_handler.error? err
      
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
    
  _getPacketFromType: (type) ->
    switch type
      when ColMetaDataPacket.type then new ColMetaDataPacket
      when DonePacket.type then new DonePacket
      when ErrorMessagePacket.type then new ErrorMessagePacket
      when InfoMessagePacket.type then new InfoMessagePacket
      when Login7Packet.type then new Login7Packet
      when LoginAckPacket.type then new LoginAckPacket
      when PreLoginPacket.type, PreLoginPacket.serverType then new PreLoginPacket
      when RowPacket.type then new RowPacket
      when SqlBatchPacket.type then new SqlBatchPacket
      else throw new Error 'Unrecognized type: ' + type 
    
  _socketData: (data) =>
    if @logDebug then console.log 'Received %d bytes', data.length
    header = null
    packet = null
    try
      @_stream.append data
      # see if we have a packet
      @_stream.beginTransaction()
      # grab packet
      header = Packet.retrieveHeader @_stream, @
      # instantiate
      packet = @_getPacketFromType header.type
      # parse
      packet.fromBuffer @_stream, @
      # commit
      @_stream.commitTransaction()
    catch err
      if err instanceof StreamIndexOutOfBoundsError
        if @logDebug then console.log 'Stream incomplete, rolling back' 
        # rollback
        @_stream.rollbackTransaction()
      else
        if @logError then console.error 'Error reading stream: ', err.stack 
        throw err
      return
    if @logDebug then console.log 'Handling packet of type %s', packet.name
    try
      # handle packet
      if packet instanceof ColMetaDataPacket
        @.columns = packet.columns
        @_handler.metadata? packet
      else if packet instanceof DonePacket
        _handler.done? packet
      else if packet instanceof ErrorMessagePacket
        switch @state
          when TdsConstants.statesByName['CONNECTING']
            @state = TdsConstants.statesByName['INITIAL']
            @end()
          when TdsConstants.statesByName['LOGGING IN']
            @state = TdsConstants.statesByName['CONNECTED']
        @_handler.error? packet
      else if packet instanceof InfoMessagePacket
        @_handler.info? packet
      else if packet instanceof LoginAckPacket
        @state = TdsConstants.statesByName['LOGGED IN']
        @_handler.login? packet
      else if packet instanceof PreLoginPacket
        @state = TdsConstants.statesByName['CONNECTED']
        @_handler.connect? packet
      else if packet instanceof RowPacket
        @_handler.row? packet
      else 
        if @logError then console.error 'Unrecognized type: ' + packet.type
        throw new Error 'Unrecognized type: ' + packet.type
    catch err
      if @logError then console.error 'Error reading stream: ', err 
      throw err
    
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
    if @logDebug then console.log 'Sending packet: %s', packet.name
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
