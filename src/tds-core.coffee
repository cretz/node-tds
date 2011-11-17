{EventEmitter} = require 'events'

class TdsCore extends EventEmitter
  
  ###*
  * All tokens used by this driver, keyed by the type number
  * they represent in the specification. 
  ###
  @tokens =
    # please keep these in order by number
    0x10: 
      name: 'LOGIN7'
      type: 0x10
      rules: [
        { length: 'DWORD' }
        { tdsVersion: 'DWORD' }
        { packetSize: 'DWORD' }
        { clientProgVer: 'DWORD' }
        { clientPid: 'DWORD' }
        { connectionId: 'DWORD' }
        { optionFlags1: '4BIT' }
        { optionFlags2: '4BIT' }
        { typeFlags: '4BIT' }
        { optionFlags3: '4BIT' }
        { timeZone: 'LONG' }
        { clientLcid: 'LONG' }
        { hostName: 'string with offset' }
        { userName: 'string with offset' }
        { password: 'string with offset' }
        { appName: 'string with offset' }
        { serverName: 'string with offset' }
        { unused: 'string with offset' }
        { progName: 'string with offset' }
        { language: 'string with offset' }
        { database: 'string with offset' }
        { clientId: '6BYTE' }
        { sspi: 'string with offset' }
        { attachDbFile: 'string with offset' }
        { changePassword: 'string with offset' }
        { sspiLong: 'DWORD' }
      ]
    0xAD:
      name: 'LOGINACK'
      type: 0xAD
      rules: [
        { length: 'USHORT' }
        { interface: 'BYTE' }
        { tdsVersion: 'DWORD' }
        { progName: 'B_VARCHAR' }
        { majorVer: 'BYTE' }
        { minorVer: 'BYTE' }
        { buildNumHi: 'BYTE' }
        { buildNumLow: 'BYTE' }
      ]
  
  ###*
  * All the tokens, keyed by their stream name
  * in the specification
  ###
  @tokensByName: { }
  
  # populate tokensByname
  for key, value of TdsCore.tokens
    TdsCore.tokensByName[value.name] = value
  
  ###*
  * Currently this can be either 7 or 8
  ###
  tdsVersion: 8
  
  socket: null
  
  _bufferStream: null
  
  ###*
  * Create a new TdsCore setup with an existing socket. The socket
  * must be initialized, but does not necessarily need to be connected
  * yet.
  * 
  * @param {net.Socket} socket The socket to use
  * @param {Object} options Possible values:
  *     <ul>
  *     <li>packetSize - The preferred packet size. Optional, default lets
  *         SQL Server choose.
  ###
  constructor: (socket, options) ->
    # set socket
    @socket = socket
    # need to add listener
    @socket.on 'data', @_onData
    # buffer stream
    @_bufferStream = new BufferStream
  
  ###*
  * Login to SQL Server
  * 
  * @param {Object} options Require options that contains:
  *     <ul>
  *     <li>host - The host name (or IP) of the database server. Required.
  *     <li>database - The name of the database. Optional, will default to
  *         user's default database
  *     <li>username - The username of the user. Required.
  *     <li>password - The password of the user. Optional, will default to
  *         no password
  *     <li>domain - The domain of the system user. Optional, will use normal
  *         authentication if not present
  *     <li>application - The name of the current application to appear inside
  *         SQL server. Optional, defaults to 'node-tds'
  *     <li>program - The name of the current program to appear inside SQL
  *         server. Optional, defaults to 'node-tds'
  *     <li>sourceHost - The name of the current host to appear inside SQL
  *         server. Optional, defaults to local hostname.
  *     <li>language - The language for server messages. Optional, defaults
  *         to what is set on the server.
  *     <li>clientId - The ID of the client. Optional, defaults to current
  *         system's MAC address.
  * @param {Function} cb Callback that will be executed upon success or failure.
  *     The first parameter will be an error (or null if success) and the second
  *     parameter will be reference to a TdsConnection (or null if failure)
  ###
  login: (options, cb) ->
    
  _onData: (data) ->
    # update buffer
    @_bufferStream.append data
    # begin buffer stream transaction
    @_bufferStream.beginTransaction
    # check next token
    try
      token = @_nextToken
      # commit since we could grab the whole token
      @_bufferStream.commitTransaction
      # fire event
      @emit 'token', token
    catch err
      if err instanceof StreamIndexOutOfBoundsError
        # rollback, not enough data yet
        @_bufferStream.rollbackTransaction
      else
        throw err
   
  _nextToken: ->
    # grab type
    tokenType = @tokens[@_bufferStream.readByte()]
    if not tokenType? then throw new Error 'Unrecognized type token type'
    # build result out of it
    # TODO
    
  _onToken: (token) ->
    
    
  _sendBuffer: (buffer) ->
    
  