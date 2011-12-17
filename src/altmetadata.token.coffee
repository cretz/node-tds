{Token} = require './token'

class AltMetaDataToken extends Token
  
  @type: 0x88
  @name: 'ALTMETADATA'

  constructor: ->
  	@type = 0x88
  	@name = 'ALTMETADATA'
  	@handlerFunction = 'altmetadata'

  fromBuffer: (stream, context) ->
  	
  	#TODO