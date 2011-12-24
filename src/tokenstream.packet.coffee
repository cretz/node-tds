{ColMetaDataToken} = require './colmetadata.token'
{DoneToken} = require './done.token'
{EnvChangeToken} = require './envchange.token'
{ErrorMessageToken} = require './error.message.token'
{InfoMessageToken} = require './info.message.token'
{LoginAckToken} = require './loginack.token'
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
      when LoginAckToken.type then new LoginAckToken
      else throw new Error 'Unrecognized type: ' + type 

  nextToken: (stream, context) ->
    type = stream.readByte()
    if context.logDebug then console.log 'Retrieved token type: ', type
    token = @_getTokenFromType type
    token.fromBuffer stream, context
    if context.logDebug then console.log 'Retrieved token: ', token
    token