{TdsConstants} = require './tds-constants'
{Token} = require './token'

class exports.DoneToken extends Token
  
  @type: 0xFD
  @name: 'DONE'
  
  constructor: ->
    @type = 0xFD
    @name = 'DONE'
    @handlerFunction = 'done'
    @__defineGetter__ 'hasMore', ->
      @status & 0x0001
    @__defineGetter__ 'isError', ->
      @status & 0x0002
    @__defineGetter__ 'hasRowCount', ->
      @status & 0x0010
    @__defineGetter__ 'isCancelled', ->
      @status & 0x0020
    @__defineGetter__ 'isFatal', ->
      @status & 0x0100
  
  fromBuffer: (stream, context) ->
    @status = stream.readUInt16LE()
    @currentCommand = stream.readUInt16LE()
    if context.tdsVersion >= TdsConstants.versionsByVersion['7.2']
      @rowCount = [stream.readUInt32LE(), stream.readUInt32LE()]
    else
      @rowCount = stream.readInt32LE()

  
