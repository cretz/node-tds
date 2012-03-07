{Token} = require './token'

###*
Token for LOGINACK (0xAD)

@spec 2.2.7.11
###
class exports.LoginAckToken extends Token
  
  @type: 0xAD
  @name: 'LOGINACK'
  
  constructor: ->
    @type = 0xAD
    @name = 'LOGINACK'
    @handlerFunction = 'loginack'
  
  fromBuffer: (stream, context) ->
    @length = stream.readUInt16LE()
    stream.assertBytesAvailable @length
    @interface = stream.readByte()
    @tdsVersion = stream.readUInt32LE()
    len = stream.readByte()
    context.debug 'Reading progName of length', len
    @progName = stream.readUcs2String len
    #stream.skip 1
    @majorVer = stream.readByte()
    @minorVer = stream.readByte()
    @buildNum = stream.readByte() << 8
    @buildNum += stream.readByte()
    