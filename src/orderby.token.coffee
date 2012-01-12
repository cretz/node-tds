{Token} = require './token'

###*
Token for ORDERBY (0xA9)

@spec 2.2.7.14
###
class exports.OrderByToken extends Token
  
  @type: 0xA9
  @name: 'ORDERBY'

  constructor: ->
    @type = 0xA9
    @name = 'ORDERBY'
    @handlerFunction = 'orderby'

  fromBuffer: (stream, context) ->
    # skip for now
    @length = stream.readUInt16LE()
    stream.skip @length