{Token} = require './token'

class exports.ReturnStatusToken extends Token
  
  @type: 0x79
  @name: 'RETURNSTATUS'
  
  constructor: ->
    @type = 0x79
    @name = 'RETURNSTATUS'
    @handlerFunction = 'returnstatus'
  
  fromBuffer: (stream, context) ->
    @value = stream.readInt32LE()
    