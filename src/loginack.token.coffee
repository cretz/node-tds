{Token} = require './token'

class exports.LoginAckToken extends Token
  
  @type: 0xAD
  @name: 'LOGINACK'
  
  constructor: ->
    @type = 0xAD
    @name = 'LOGINACK'
  
  fromBuffer: (stream, context) ->
    @length = stream.readUInt16LE()
    stream.assertBytesAvailable @length
    @interface = stream.readByte()
    @tdsVersion = stream.readUInt32LE()
    len = stream.readByte()
    if context.logDebug then console.log 'Reading progName of length', len
    @progName = stream.readUcs2String len
    #stream.skip 1
    @majorVer = stream.readByte()
    @minorVer = stream.readByte()
    @buildNum = stream.readByte() << 8
    @buildNum += stream.readByte()
    