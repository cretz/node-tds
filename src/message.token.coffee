{TdsConstants} = require './tds-constants'
{Token} = require './token'

class exports.MessageToken extends Token
  
  fromBuffer: (stream, context) ->
    # assert length
    @length = stream.readUInt16LE()
    stream.assertBytesAvailable len
    @number = stream.readInt32LE()
    @state = stream.readByte()
    @severity = stream.readByte()
    @text = stream.readUcs2String stream.readUInt16LE()
    @procName = stream.readUcs2String stream.readUInt16LE()
    if @context.tdsVersion >= TdsConstants.versionsByVersion['7.2']
      @lineNumber = stream.readInt32LE()
    else
      @lineNumber = stream.readUInt16LE()
    