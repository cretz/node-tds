{Packet} = require './packet'

class exports.LoginAckPacket extends Packet
  
  @type: 0xAD
  
  @name: 'LOGINACK'
  
  interface: 0

  tdsVersion: 0
  
  progName: ''

  majorVer: 0
  
  minorVer: 0
  
  buildNum: 0
  
  fromBuffer: (stream) ->
    stream.assertBytesAvailable stream.readUInt16LE()
    @interface = stream.readByte()
    @tdsVersion = stream.readUInt32LE()
    @progName = stream.readUcs2String stream.readByte() - 1
    stream.skip 1
    @majorVer = stream.readByte()
    @minorVer = stream.readByte()
    @buildNum = stream.readByte() << 8
    @buildNum = stream.readByte()
    