{TdsConstants} = require './tds-constants'
{Token} = require './token'

class exports.DoneToken extends Token
  
  @type: 0xFD
  @name: 'DONE'
  
  constructor: ->
    @type = 0xFD
    @name = 'DONE'
  
  fromBuffer: (stream, context) ->
    @status = stream.readUInt16LE()
    @currentCommand = stream.readUInt16LE()
    if context.tdsVersion >= TdsConstants.versionsByVersion['7.2']
      @rowCount = [stream.readUInt32LE(), stream.readUInt32LE()]
    else
      @rowCount = stream.readInt32LE()
