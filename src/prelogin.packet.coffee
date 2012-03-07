{Packet} = require './packet'

###*
Packet for PRELOGIN (0x12)

@spec 2.2.6.4
###
class exports.PreLoginPacket extends Packet
  
  @type: 0x12
  @name: 'PRELOGIN'

  constructor: ->
    @type = 0x12
    @name = 'PRELOGIN'

  fromBuffer: (stream, context) ->
    pendingValues = []
    while stream.readByte() isnt 0xFF
      stream.overrideOffset stream.currentOffset() - 1
      pendingValues.push
        type: stream.readUInt16LE()
        offset: stream.readUInt16LE()
        length: stream.readByte()
      if context.logDebug
        val = pendingValues[pendingValues.length - 1]
        context.debug 'Added pending value type: %d, offset: %d, length: %d',
          val.type, val.offset, val.length
    for pendingValue in pendingValues
      switch pendingValue.type
        when 0
          @version = stream.readBytes 6
          context.debug 'Version: ', @version
        when 1
          @encryption = stream.readByte()
          context.debug 'Encryption: ', @encryption
        when 2
          context.debug 'Reading instance name of length: %d', pendingValue.length
          @instanceName = stream.readAsciiString pendingValue.length - 1
          stream.skip 1
          context.debug 'Instance name: ', @instanceName
        when 3
          # ignore this coming from the server
          context.debug 'Ignoring thread ID: '
        else stream.skip pendingValue.length
        
  toBuffer: (builder, context) ->
    # version
    @version ?= [0x08, 0x00, 0x01, 0x55, 0x00, 0x00]
    if @version.length isnt 6 then throw new Error 'Invalid version length'
    builder.appendUInt16LE 0
    builder.appendUInt16LE 21
    builder.appendByte 6
    # encryption
    @encryption ?= 2
    builder.appendUInt16LE 1
    builder.appendUInt16LE 27
    builder.appendByte 1
    # instanceName
    @instanceName ?= ''
    builder.appendUInt16LE 2
    builder.appendUInt16LE 28
    builder.appendByte @instanceName.length + 1
    # threadId
    @threadId ?= process.pid
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
    @insertPacketHeader builder, context

  