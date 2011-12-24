{TdsConstants} = require './tds-constants'
{Token} = require './token'

class exports.EnvChangeToken extends Token

  @type: 0xE3
  @name: 'ENVCHANGE'

  constructor: ->
  	@type = 0xE3
  	@name = 'ENVCHANGE'

  _readValue: (typedef, stream, context) ->
  	if not typedef?
  	  stream.skip 1
  	  null
  	else if typedef is '2byteskip'
  	  stream.skip 2
  	  null
  	else
  	  switch typedef
  	    when 'string' then stream.readUcs2String stream.readByte()
  	    when 'bytes' then stream.readBuffer stream.readByte()
  	    when 'byte' then stream.readByte()
  	    when 'longbytes' then stream.readBuffer stream.readUInt32LE()
  	    when 'shortbytes' then stream.readBuffer stream.readUInt16LE()
  	    else throw new Error 'Unrecognized typedef: ' + typedef

  fromBuffer: (stream, context) ->
  	@length = stream.readUInt16LE()
  	@changeType = stream.readByte()
  	stream.assertBytesAvailable @length
  	typedef = TdsConstants.envChangeTypesByNumber[@changeType]
  	if not typedef?
  	  throw new Error 'Unrecognized envchange type: ' + @changeType
  	@newValue = @_readValue typedef.newValue, stream, context
  	@oldValue = @_readValue typedef.oldValue, stream, context
