{Token} = require './token'

class exports.EnvChangeToken extends Token

  @type: 0xE3
  @name: 'ENVCHANGE'

  constructor: ->
  	@type = 0xE3
  	@name = 'ENVCHANGE'

  fromBuffer: (stream, context) ->
  	@length = stream.readUInt16LE()
  	# skip for now
  	stream.skip @length