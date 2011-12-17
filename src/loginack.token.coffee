{Token} = require './token'

class exports.LoginAckToken extends Token
  
  @type: 0xAD
  @name: 'LOGINACK'
  
  constructor: ->
    type: 0xAD
    name: 'LOGINACK'
  
  fromBuffer: (stream, context) ->
    @length = 2 + stream.readUInt16LE()
    stream.assertBytesAvailable @length - 2
    @interface = stream.readByte()
    @tdsVersion = stream.readUInt32LE()
    @progName = stream.readUcs2String stream.readByte() - 1
    stream.skip 1
    @majorVer = stream.readByte()
    @minorVer = stream.readByte()
    @buildNum = stream.readByte() << 8
    @buildNum += stream.readByte()
    