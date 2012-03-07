{TdsConstants} = require './tds-constants'
{Token} = require './token'

###*
Token for DONE (0xFD), DONEINPROC (0xFD), and DONEPROC (0xFE)

@spec 2.2.7.5
@spec 2.2.7.6
@spec 2.2.7.7
###
class exports.DoneToken extends Token
  
  @type: 0xFD
  @type2: 0xFF #DONEINPROC
  @type3: 0xFE #DONEPROC
  @name: 'DONE'
  
  constructor: ->
    @type = 0xFD
    @name = 'DONE'
    @handlerFunction = 'done'
    @__defineGetter__ 'hasMore', =>
      @status & 0x01 isnt 0
    @__defineGetter__ 'isError', =>
      @status & 0x02 isnt 0
    @__defineGetter__ 'hasRowCount', =>
      @status & 0x10 isnt 0
    # meh, spell it both ways, why not
    @__defineGetter__ 'isCanceled', =>
      @status & 0x20 isnt 0
    @__defineGetter__ 'isCancelled', =>
      @status & 0x20 isnt 0
    @__defineGetter__ 'isFatal', =>
      @status & 0x100 isnt 0
  
  fromBuffer: (stream, context) ->
    @status = stream.readUInt16LE()
    @currentCommand = stream.readUInt16LE()
    if context.tdsVersion >= TdsConstants.versionsByVersion['7.2']
      @rowCount = [stream.readUInt32LE(), stream.readUInt32LE()]
    else
      @rowCount = stream.readInt32LE()