{Socket} = require 'net'
{EventEmitter} = require 'events'

{BufferBuilder} = require './buffer-builder'
{BufferStream, StreamIndexOutOfBoundsError} = require './buffer-stream'
{ColMetaDataPacket} = require './colmetadata'
{DonePacket} = require './done.packet'
{ErrorMessagePacket} = require './error.message.packet'
{InfoMessagePacket} = require './info.message.packet'
{Login7Packet} = require './login7.packet'
{LoginAckPacket} = require './loginack.packet'
{Packet} = require './packet'
{PreLoginPacket} = require './prelogin.packet'
{RowPacket} = require './row.packet'
{SqlBatchPacket} = require './sqlbatch.packet'

class exports.TdsClient extends EventEmitter
  
  _socket: null
  _preLoginConfig: null
  _stream: null
  
  logDebug: false
  logError: false
    
  connect: (config) ->
    if @logDebug then console.log 'Connecting to SQL Server with config %j', config
    try
      @_preLoginConfig = config
      # create socket
      @_socket = new Socket
      # attach listeners
      @_socket.on 'connect', @_socketConnect
      @_socket.on 'error', @_socketError
      @_socket.on 'data', @_socketData
      @_socket.on 'end', @_socketEnd
      # attempt connect
      @_socket.connect config.port ? 1433, config.host ? 'localhost'
    catch err
      if @logError then console.error 'Error connecting: ', err 
      @emit 'error', err
    
  login: (config) ->
    if @logDebug then console.log 'Logging in with config %j', config 
    try
      # create packet
      login = new Login7Packet
      for key, value of config
        if login.hasOwnProperty key
          login[key] = value
      # send
      @_sendPacket login
    catch err
      if @logError then console.error 'Error on login: ', err 
      @emit 'error', err
    
  sqlBatch: (sqlText) ->
    if @logDebug then console.log 'Executing SQL Batch: %s', sqlText
    try
      # create packet
      sqlBatch = new SqlBatchPacket
      sqlBatch.sqlText = sqlText
      # send
      @_sendPacket sqlBatch
    catch err
      if @logError then console.error 'Error executing: ', err 
      @emit 'error', err
      
  _socketConnect: ->
    if @logDebug then console.log 'Connection established, pre-login commencing'
    try
      # create new stream
      @_stream = new BufferStream
      # do prelogin
      prelogin = new PreLoginPacket
      for key, value of config
        if prelogin.hasOwnProperty key
          prelogin[key] = value
      @_sendPacket prelogin
    catch err
      if @logError then console.error 'Error on pre-login: ', err 
      @emit 'error', err    
    
  _socketError: (error) ->
    if @logError then console.error 'Error in socket: ', error
    @emit 'error', error
    
  _socketData: (data) ->
    if @logDebug then console.log 'Received %d bytes', data.length
    header = null
    packet = null
    try
      @_stream.append data
      # see if we have a packet
      @_stream.beginTransaction()
      # grab packet
      header = Packet.retrieveHeader @_stream
      if TdsConstants.packets[header.type]?
        throw new Error 'Unrecognized type: ' + header.type
      # instantiate
      packet = new TdsConstants.packets[header.type]
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
        if @logError then console.error 'Error reading stream: ', err 
        @emit 'error', err
    if @logDebug then console.log 'Handling packet of type %s', packet.name
    try
      # handle packet
      switch packet.type
        when ColMetaDataPacket.type
          @.columns = packet.columns
          @emit 'metadata', packet
        when DonePacket.type
          @emit 'done', packet
        when ErrorMessagePacket.type
          @emit 'error', packet
        when InfoMessagePacket.type
          @emit 'info', packet
        when LoginAckPacket.type
          @emit 'login', packet
        when PreLoginPacket.type
          @emit 'connect', packet
        when RowPacket.type
          @emit 'row', packet
        else @emit 'error', new Error 'Unrecognized type: ' + packet.type
    catch err
      if @logError then console.error 'Error reading stream: ', err 
      @emit 'error', err
    
  _socketEnd: ->
    if @logDebug then console.log 'Socket ended remotely' 
    @_socket = null
    @emit 'end'
    
  _sendPacket: (packet) ->
    @_socket.write packet.toBuffer(new BufferBuilder, @)
    
  end: ->
    if @logDebug then console.log 'Ending socket' 
    @_socket.end()
