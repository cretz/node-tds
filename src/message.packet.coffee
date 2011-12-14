{Packet} = require './packet'

class exports.MessagePacket extends Packet
  
  fromBuffer: (stream, context) ->
    # assert length
    len = stream.readUInt16LE()
    stream.assertBytesAvailable len
    @number = stream.readInt32LE()
    @state = stream.readByte()
    @severity = stream.readByte()
    @text = stream.readUcs2String stream.readUInt16LE()
    @procName = stream.readUcs2String stream.readUInt16LE()
    @lineNumber = stream.readInt32LE()
    