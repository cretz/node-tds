{MessageToken} = require './message.token'

###*
Token for ERROR (0xAA)

@spec 2.2.7.9
###
class exports.ErrorMessageToken extends MessageToken
  
  @type: 0xAA
  @name: 'ERROR'

  constructor: ->
    @type = 0xAA
    @name = 'ERROR'
    @error = true
    @handlerFunction = 'message'
