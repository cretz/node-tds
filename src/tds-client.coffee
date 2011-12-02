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
  
  _socket: null
  _preLoginConfig: null
  _stream: null
  _handler: null
  
  logDebug: false
  logError: false
  state: TdsConstants.statesByName['INITIAL']
  
  constructor: (@_handler) ->
    if @_handler? then throw new Error 'Handler required'
    
  connect: (config) ->
    if @state isnt TdsConstants.statesByName['INITIAL']
      throw new Error 'Client must be in INITIAL state before connecting'
    @state = TdsConstants.statesByName['CONNECTING']
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
      @state = TdsConstants.statesByName['INITIAL']
      @_handler.error? err
      end()
    
  login: (config) ->
    if @state isnt TdsConstants.statesByName['CONNECTED']
      throw new Error 'Client must be in CONNECTED state before logging in'
    @state = TdsConstants.statesByName['LOGGING IN']
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
      @state = TdsConstants.statesByName['INITIAL']
      @_handler.error? err
      @end()
    
  _socketError: (error) ->
    if @logError then console.error 'Error in socket: ', error
    @_handler.error? err
    @end()
    
  _getPacketFromType: (type) ->
    switch type
      when ColMetaDataPacket.type then ColMetaDataPacket
      when DonePacket.type then DonePacket
      when ErrorMessagePacket.type then ErrorMessagePacket
      when InfoMessagePacket.type then InfoMessagePacket
      when Login7Packet.type then Login7Packet
      when LoginAckPacket.type then LoginAckPacket
      when PreLoginPacket.type then PreLoginPacket
      when RowPacket.type then RowPacket
      when SqlBatchPacket.type then SqlBatchPacket
      else throw new Error 'Unrecognized type: ' + header.type 
    
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
      # instantiate
      packet = new @_getPacketFromType header.type
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
        throw err
      return
    if @logDebug then console.log 'Handling packet of type %s', packet.name
    try
      # handle packet
      switch packet.type
        when ColMetaDataPacket.type
          @.columns = packet.columns
          @_handler.metadata? packet
        when DonePacket.type
          @_handler.done? packet
        when ErrorMessagePacket.type
          switch @state
            when TdsConstants.statesByName['CONNECTING']
              @state = TdsConstants.statesByName['INITIAL']
              @end()
            when TdsConstants.statesByName['LOGGING IN']
              @state = TdsConstants.statesByName['CONNECTED']
          @_handler.error? packet
        when InfoMessagePacket.type
          @_handler.info? packet
        when LoginAckPacket.type
          @state = TdsConstants.statesByName['LOGGED IN']
          @_handler.login? packet
        when PreLoginPacket.type
          @state = TdsConstants.statesByName['CONNECTED']
          @_handler.connect? packet
        when RowPacket.type
          @_handler.row? packet
        else 
          if @logError then console.error 'Unrecognized type: ' + packet.type
          throw new Error 'Unrecognized type: ' + packet.type
    catch err
      if @logError then console.error 'Error reading stream: ', err 
      throw err
    
  _socketEnd: ->
    if @logDebug then console.log 'Socket ended remotely' 
    @_socket = null
    @state = TdsConstants.statesByName['INITIAL']
    
  _sendPacket: (packet) ->
    @_socket.write packet.toBuffer(new BufferBuilder, @)
    
  end: ->
    if @logDebug then console.log 'Ending socket' 
    try
      @_socket.end()
    @_socket = null
    @state = TdsConstants.statesByName['INITIAL']
