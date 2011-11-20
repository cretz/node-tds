class PreLoginPacket extends Packet
  
  type: 0x12
  
  name: 'PRELOGIN'
  
  version: [0x08, 0x00, 0x01, 0x55, 0x00, 0x00]
  
  encryption: 2
  
  instanceName: ''
  
  threadId: process.pid
  
  fromBuffer: (stream) ->
    pendingValues = []
    while tokenType = stream.readUInt16LE() isnt 0xFF
      pendingValues.push
        type: tokenType
        offset: stream.readUInt16LE()
        length: stream.readByte()
    for pendingValue in pendingValues
      switch pendingValue.type
        when 0 then @version = stream.readBytes 6
        when 1 then @encryption = stream.readByte() is 1
        when 2 
          @instanceName = stream.readAsciiString pendingValue.length - 1
          stream.skip 1
        when 3 then @threadId = stream.readUInt32LE()
        else stream.skip pendingValue.length
        
  toBuffer: (builder) ->
    # version
    if @version.length isnt 6 then throw new Error 'Invalid version length'
    builder.appendUInt16LE 0
    builder.appendUInt16LE 21
    builder.appendByte 6
    # encryption
    builder.appendUInt16LE 1
    builder.appendUInt16LE 27
    builder.appendByte 1
    # instanceName
    @instanceName ?= ''
    builder.appendUInt16LE 2
    builder.appendUInt16LE 28
    builder.appendByte @instanceName.length + 1
    # threadId
    @threadId ?= 0
    builder.appendUInt16LE 3
    builder.appendUInt16LE @instanceName.length + 29
    builder.appendByte 4
    # terminator
    builder.appendByte 0xFF
    # values
    builder.appendBytes @version
    builder.appendByte @encryption
    builder.appendAsciiString(@instanceName).appendByte 0
    builder.appendUInt32LE @threadId
    # header
    @insertPacketHeader builder

    