{MessageToken} = require './message.token'

###*
Token for INFO (0xAB)

@spec 2.2.7.10
###
class exports.InfoMessageToken extends MessageToken
  
  @type: 0xAB
  @name: 'INFO'

  constructor: ->
    @type = 0xAB
    @name = 'INFO'
    @error = false
    @handlerFunction = 'message'
