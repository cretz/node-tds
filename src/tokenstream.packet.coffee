{ColMetaDataToken} = require './colmetadata.token'
{DoneToken} = require './done.token'
{EnvChangeToken} = require './envchange.token'
{ErrorMessageToken} = require './error.message.token'
{InfoMessageToken} = require './info.message.token'
{Packet} = require './packet'

class exports.TokenStreamPacket extends Packet

  @type: 0x04
  @name: 'TokenStream'

  constructor: ->
  	@type = 0x04
  	@name = 'TokenStream'
  	@tokens = []

  _getTokenFromType: (type) ->
  	switch type
      when ColMetaDataToken.type then new ColMetaDataToken
      when DoneToken.type then new DoneToken
      when EnvChangeToken.type then new EnvChangeToken
      when ErrorMessageToken.type then new ErrorMessageToken
      when InfoMessageToken.type then new InfoMessageToken
      else throw new Error 'Unrecognized type: ' + type 

  nextToken: (stream, context) ->
    token = @_getTokenFromType stream.readByte()
    token.fromBuffer stream, context
    token