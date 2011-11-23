class Login7Packet extends Packet
  
  @type: 0x10
  
  @name: 'LOGIN7'
  
  ###*
  * The version of TDS to use.
  * Default is 0x71000001
  ###
  tdsVersion: 0x71000001
  
  ###*
  * How big the packets should be.
  * Default is 0 (SQL server decides)
  ###
  packetSize: 0
  
  ###*
  * The client version.
  * Default is 7
  ###
  clientProgramVersion: 7
  
  ###*
  * The client process ID.
  * Default is the current process ID
  ###
  clientProcessId: process.pid
  
  ###*
  * The connection ID.
  * Default is 0
  ###
  connectionId = 0
  
  optionFlags1: 0
  
  optionFlags2: 0x03
  
  typeFlags: 0
  
  optionFlags3: 0
  
  clientTimeZone: 0
  
  clientLcid: 0
  
  hostName: require('os').hostname()

  domain: ''
  
  userName: ''
  
  password: ''
  
  appName: 'node-tds'
  
  serverName: ''
  
  unused: ''
  
  interfaceLibraryName: 'node-tds'
  
  language: ''
  
  database: ''
  
  clientId: [0, 0, 0, 0, 0, 0]

  toBuffer: (builder) ->
    # validate
    if @serverName.length is 0 then throw new Error 'serverName not specified'
    if @userName.length is 0 then throw new Error 'userName not specified'
    if @domain.length > 0 then throw new Error 'NTLM not yet supported'
    # type
    builder.append
    # length
    length = 86 + 2 * (
      @hostName.length +
      @appName.length +
      @serverName.length +
      @interfaceLibraryName.length +
      @language.length +
      @database.length
    ) 
    builder.appendUInt32LE length
    # standard vals
    builder.appendUInt32LE @tdsVersion
    builder.appendUInt32LE @packetSize
    builder.appendUInt32LE @clientProgramVersion
    builder.appendUInt32LE @clientProcessId
    builder.appendUInt32LE @connectionId
    builder.appendByte @optionFlags1
    builder.appendByte @optionFlags2
    builder.appendByte @typeFlags
    builder.appendByte @optionFlags3
    builder.appendUInt32LE @clientTimeZone
    builder.appendUInt32LE @clientLcid
    # strings
    curPos = 86
    # serverName
    builder.appendUInt16LE curPos
    builder.appendUInt16LE @hostName.length
    curPos += @hostName.length * 2
    # userName
    builder.appendUInt16LE curPos
    builder.appendUInt16LE @userName.length
    curPos += @userName.length * 2
    # password
    builder.appendUInt16LE curPos
    builder.appendUInt16LE @password.length
    curPos += @password.length * 2
    # appName
    builder.appendUInt16LE curPos
    builder.appendUInt16LE @appName.length
    curPos += @appName.length * 2
    # serverName
    builder.appendUInt16LE curPos
    builder.appendUInt16LE @serverName.length
    curPos += @serverName.length * 2
    # unused
    builder.appendUInt16LE curPos
    builder.appendUInt16LE @unused.length
    curPos += @unused.length * 2
    # interfaceLibraryName
    builder.appendUInt16LE curPos
    builder.appendUInt16LE @interfaceLibraryName.length
    curPos += @interfaceLibraryName.length * 2
    # language
    builder.appendUInt16LE curPos
    builder.appendUInt16LE @language.length
    curPos += @language.length * 2
    # database
    builder.appendUInt16LE curPos
    builder.appendUInt16LE @database.length
    curPos += @database.length * 2
    # clientId
    builder.appendBytes @clientId
    # NTLM not supported right now
    builder.appendUInt16LE curPos
    builder.appendUInt16LE 0
    # offset length
    builder.appendUInt32LE length
    # strings
    builder.appendUcs2String @hostName
    builder.appendUcs2String @userName
    builder.appendBuffer @_encryptPass()
    builder.appendUcs2String @appName
    builder.appendUcs2String @serverName
    builder.appendUcs2String @interfaceLibraryName
    builder.appendUcs2String @language
    builder.appendUcs2String @database
    # header
    @insertPacketHeader builder

  _encryptPass: ->
    ret = new Buffer @password, 'ucs2'
    for i in [0..@password.length - 1]
      byte = ret[i]
      ret[i] = ((byte & 0x0f) | (byte >> 4)) ^ 0xA5
    ret

