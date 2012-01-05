{Token} = require './token'

###*
Token for ALTMETADATA (0x88)

@spec 2.2.7.1
###
class AltMetaDataToken extends Token
  
  @type: 0x88
  @name: 'ALTMETADATA'

  constructor: ->
    @type = 0x88
    @name = 'ALTMETADATA'
    @handlerFunction = 'altmetadata'

  fromBuffer: (stream, context) ->
  	#TODO