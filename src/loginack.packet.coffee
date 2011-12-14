{Packet} = require './packet'

class exports.LoginAckPacket extends Packet
  
  @type: 0xAD
  @name: 'LOGINACK'
  
  constructor: ->
    type: 0xAD
    name: 'LOGINACK'
  
  fromBuffer: (stream, context) ->
    stream.assertBytesAvailable stream.readUInt16LE()
    @interface = stream.readByte()
    @tdsVersion = stream.readUInt32LE()
    @progName = stream.readUcs2String stream.readByte() - 1
    stream.skip 1
    @majorVer = stream.readByte()
    @minorVer = stream.readByte()
    @buildNum = stream.readByte() << 8
    @buildNum += stream.readByte()
    