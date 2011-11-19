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
      send: true
      rules: [
        { name: 'length', type: 'DWORD' }
        { name: 'tdsVersion', type: 'DWORD' }
        { name: 'packetSize', type: 'DWORD' }
        { name: 'clientProgVer', type: 'DWORD' }
        { name: 'clientPid', type: 'DWORD' }
        { name: 'connectionId', type: 'DWORD' }
        { name: 'optionFlags1', type: '4BIT' }
        { name: 'optionFlags2', type: '4BIT' }
        { name: 'typeFlags', type: '4BIT' }
        { name: 'optionFlags3', type: '4BIT' }
        { name: 'timeZone', type: 'LONG' }
        { name: 'clientLcid', type: 'LONG' }
        { name: 'hostName', type: 'pending-value', subType: 'string' }
        { name: 'userName', type: 'pending-value', subType: 'string' }
        { name: 'password', type: 'pending-value', subType: 'string' }
        { name: 'appName', type: 'pending-value', subType: 'string' }
        { name: 'serverName', type: 'pending-value', subType: 'string' }
        { name: 'unused', type: 'pending-value', subType: 'string' }
        { name: 'progName', type: 'pending-value', subType: 'string' }
        { name: 'language', type: 'pending-value', subType: 'string' }
        { name: 'database', type: 'pending-value', subType: 'string' }
        { name: 'clientId', type: '6BYTE' }
        { name: 'sspi', type: 'pending-value', subType: 'string' }
        { name: 'attachDbFile', type: 'pending-value', subType: 'string' }
        { name: 'changePassword', type: 'pending-value', subType: 'string' }
        { name: 'sspiLong', type: 'DWORD' }
      ]
    0x12:
      name: 'PRELOGIN'
      type: 0x12
      send: true
      rules: [
        name: 'options', type: 'pre-login-options', rules: [
          { name: #TODO 
          }
        ]
      ]
    0xAD:
      name: 'LOGINACK'
      type: 0xAD
      receive: true
      rules: [
        { name: 'length', type: 'USHORT' }
        { name: 'interface', type: 'BYTE' }
        { name: 'tdsVersion', type: 'DWORD' }
        { name: 'progName', type: 'B_VARCHAR' }
        { name: 'majorVer', type: 'BYTE' }
        { name: 'minorVer', type: 'BYTE' }
        { name: 'buildNumHi', type: 'BYTE' }
        { name: 'buildNumLow', type: 'BYTE' }
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
  * The version of TDS to use.
  * Currently this can be either 7 or 8.
  * Default is 8
  ###
  tdsVersion: 8
  
  ###*
  * How big the packets should be.
  * Default is 0 (SQL server decides)
  ###
  preferredPacketSize: 0
  
  ###*
  * The client version.
  * Default is 7
  ###
  clientProgramVersion: 7
  
  ###*
  * The connection ID.
  * Default is 0
  ###
  connectionId = 0
  
  ###*
  * The client process ID.
  * Default is the current process ID
  ###
  clientProcessId: require('process').pid
  
  ###*
  * The socket in use. Do not set this field directly,
  * it is set by the constructor.
  ###
  socket: null
  
  ###*
  * The amount of time in milliseconds
  * to wait before timing out during initial
  * TDS connection. Null means no timeout.
  * Default is 15 seconds.
  * TODO
  ###
  connectionTimeout: 15000
  
  ###*
  * The amount of time in milliseconds
  * during a query before this will timeout.
  * Null means no timeout. Default is no timeout.
  * TODO
  ###
  requestTimeout: null
  
  ###*
  * The amount of time in milliseconds
  * during a query cancellation to wait
  * for acknowledgment. Null means no timeout.
  * Default is no timeout.
  * TODO
  ###
  cancelTimeout: null
  
  ###*
  * The current state of TDS
  * TODO
  ###
  state: null
  
  # the buffer stream
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
  * Perform pre-login setup
  * 
  * @param {Object} options Object that can contain:
  *     <ul>
  *     <li>version - The 6 byte-sized version to use. The first four
  *         are the version, the next two are the sub build.
  *         Defaults to 8.341.0 if not specified.
  *     <li>encryption - Whether or not encryption should
  *         be used. Defaults to true if not specified.
  *     <li>instanceName - The name of the server instance.
  *         Defaults to nothing if not specified.
  *     <li>threadId - The thread ID. Defaults to the
  *         clientProcessId value if not specified.
  *     
  ###
  preLogin: (options) ->
    # create token
    token =
      options: [
        { type: '6BYTE', value: options.version ? [0x08, 0x00, 0x01, 0x55, 0x00, 0x00] }
        { type: 'BYTE', value: if options.encryption? and not options.encryption then 0 else 1 }
        { type: 'ascii string with offset', value: options.instanceName ? '' }
        { type: 'ULONG', value: options.threadId ? @clientProcessId }
      ]
    # send
    @_writeToken @tokensByName.PRELOGIN.type, token
  
  ###*
  * Login to SQL Server
  * 
  * @param {Object} options Object that contains:
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
  ###
  login: (options) ->
    # check
    if not options.host? then throw new Error 'Host not specified'
    if not options.username? then throw new Error 'Username not specified'
    # TODO - support NTLM
    if options.domain? then throw new Error 'NTLM not yet supported'
    # build token
    token =
      tdsVersion: @tdsVersion
      packetSize: @preferredPacketSize
      clientProgVer: @clientProgramVersion
      clientPid: @clientProcessId
      connectionId: @connectionId
      # TODO - expose flags
      optionFlags1: 0
      optionFlags2: 0x03 # say we're an ODBC-ish driver
      typeFlags: 0
      optionFlags3: 0
      # TODO - expose time zone and collation
      timeZone: 0
      clientLcid: 0
      hostName: options.sourceHost ? require('os').hostname()
      # no username or password for NTLM auth
      userName: if options.domain? then '' else options.username
      password: if options.domain? then '' else options.password ? ''
      appName: options.application ? 'node-tds'
      serverName: options.host
      progName: options.program ? 'node-tds'
      language: options.language ? ''
      database: options.database ? ''
      # TODO - obtain MAC address
      clientId: [0, 0, 0, 0, 0, 0]
      # NTLM if domain provided (TODO)
      sspi: ''
    # send
    @_writeToken @tokensByName.LOGIN7.type, token
    
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
      @emit 'token', token if token?
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
    # return parsed token
    @_parseToken tokenType
      
  _parseToken: (tokenType) ->
    ret = {}
    pendingValues = []
    # go through the rules
    for rule in tokenType.rules
      # set the value
      ret[rule[0]] = @_parseValue rule[1], pendingValues
    
    # populate pending strings
    maxOffset = -1
    for pendingValue in pendingValues
      if pendingvalue.length > 0
        ret[pendingValue.name] = @_parseValue pendingValue.type, null, pendinValue.index, pendingValue.length
        if pendingValue.index + pendingValue.length > maxOffset
          maxOffset = pendingValue.index + pendingValue.length
    # reset the offset
    if maxOffset > @_bufferStream.currentOffset()
      @_bufferStream.overrideOffset maxOffset
    
    # return
    ret
    
  _parseValue: (type, pendingValues, index = -1, length = -1) ->
    switch type
      # please keep in alphabetical order
      when '4BIT' then @_bufferStream.readByte()
      when '6BYTE' then @_bufferStream.readBytes 6
      when 'DWORD' then @_bufferStream.readUInt32LE()
      when 'LONG' then @_bufferStream.readInt32LE()
      when 'pending-value'
        #add pending value
        pendingValues.push
          index: @_bufferStream.readUInt16LE()
          length: @_bufferStream.readUInt16LE()
          name: rule[0]
          type: rule[2]
        null
      when 'pre-login options'
        pendingValues.push
      when 'string' then @_bufferStream.readUcs2StringFromIndex index, length
      else throw new Error 'Unrecognized type: ' + type 
        
  _writeToken: (tokenType, token, endOfMessage = true) ->
    bldr = new BufferBuilder
    pending =
      values: []
      dataOffset: 0
    # go through the rules in order
    for rule in tokenType.rules
      val = token[rule[0]]
      # we skip ignored vals
      if val? then @_writeValue rule[1], val, bldr, pending, if rule.length > 1 then rule[2] else null
            
    # add the pending strings to the end
    for pendingValue in pending.values
      @_writeValue pendingValue.type, pendingValue.value, bldr
    
    # add in header information
    # packet type
    bldr.insertByte tokenType.type, 0 
    # status
    bldr.insertByte (if endOfMessage then 1 else 0), 1
    # length (current length + 6 for the more we're gonna add to the header)
    bldr.insertUInt16BE bldr.length + 5, 2
    # process id (always 0)
    bldr.insertByte 0, 4
    bldr.insertByte 0, 5
    # packet ID (ignored, setting to 1)
    bldr.insertByte 1, 6
    # window (unused, always 0)
    bldr.insertByte 0, 7
    
    #now write
    @socket.write bldr.toBuffer()
    
  _writeValue: (type, val, bldr, pending = null, subType = null) ->
    switch type
      # please keep in alphabetical order
      when '4BIT' then bldr.appendByte val
      when '6BYTE' then bldr.appendBytes val
      when 'DWORD' then bldr.appendUInt32LE val
      when 'LONG' then bldr.appendInt32LE val
      when 'pending-value'
        # add the expected position, length, and pending value
        bldr.appendUInt16LE pending.dataOffset + bldr.length
        if val? and val isnt ''
          bldr.appendUInt16LE @_getActualLength subType, val
          pending.dataOffset += @_getByteLength val
          pending.values.push
            type: subType, value: val
        else
          # blank it out
          bldr.appendUInt16LE 0
      when 'pre-login options'
        for opt in val
          @_writeValue 'pending-value', opt.value, bldr, pending, opt.type
      else throw new Error 'Unrecognized type: ' + type
      
  _getActualLength: (type, val) ->
    switch type
      when 'string' then val.length
      else @_getByteLength type, val
      
  _getByteLength: (type, val) ->
    switch type
      when '4BIT' then 1
      when 'DWORD', 'LONG' then 4
      when '6BYTE' then 6
      when 'string' then BufferBuilder.getUcs2StringLength val
      else throw new Error 'Unrecognized type: ' + type 
  
  _onToken: (token) ->
    
    
  _sendBuffer: (buffer) ->
    
  