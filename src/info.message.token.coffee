{MessageToken} = require './message.token'

class exports.InfoMessageToken extends MessageToken
  
  @type: 0xAB
  @name: 'INFO'

  constructor: ->
  	@type = 0xAB
  	@name = 'INFO'
