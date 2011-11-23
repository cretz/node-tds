net = require 'net'
{EventEmitter} = require 'events'

class TdsClient extends EventEmitter
  
  _socket: null
  _preLoginConfig: null
  _stream: null
  _context: { }
    
  connect: (config) ->
    try
      @_preLoginConfig = config
      # create socket
      @_socket = new net.Socket
      # attach listeners
      @_socket.on 'connect', @_socketConnect
      @_socket.on 'error', @_socketError
      @_socket.on 'data', @_socketData
      @_socket.on 'end', @_socketEnd
      # attempt connect
      @_socket.connect config.port ? 1433, config.host ? 'localhost'
    catch err
      @emit 'error', err
    
  login: (config) ->
    try
      # create packet
      login = new Login7Packet
      for key, value of config
        if login.hasOwnProperty key
          login[key] = value
      # send
      @_sendPacket login
    catch err
      @emit 'error', err
    
  sql: (sqlText) ->
    try
      # create packet
      sqlBatch = new SqlBatchPacket
      sqlBatch.sqlText = sqlText
      # send
      @_sendPacket sqlBatch
    catch err
      @emit 'error', err
      
  _socketConnect: ->
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
      @emit 'error', err    
    
  _socketError: (error) ->
    @emit 'error', error
    
  _socketData: (data) ->
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
      packet.fromBuffer @_stream, @_context
      # commit
      @_stream.commitTransaction()
    catch err
      if err instanceof StreamIndexOutOfBoundsError
        # rollback
        @_stream.rollbackTransaction()
      else
        @emit 'error', err
    try
      # handle packet
      switch packet.type
        when ColMetaDataPacket.type
          @_context.columns = packet.columns
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
      @emit 'error', err
    
  _socketEnd: ->
    @_socket = null
    @emit 'end'
    
  _sendPacket: (packet) ->
    @_socket.write packet.toBuffer(new BufferBuilder, @_context)
    
  end: ->
    @_socket.end()
