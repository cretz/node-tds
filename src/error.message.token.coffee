{MessageToken} = require './message.token'

class exports.ErrorMessageToken extends MessageToken
  
  @type: 0xAA
  @name: 'ERROR'

  constructor: ->
    @type = 0xAA
    @name = 'ERROR'
    @error = true
    @handlerFunction = 'message'
