{ColMetaDataToken} = require './colmetadata.token'
{DoneToken} = require './done.token'
{EnvChangeToken} = require './envchange.token'
{ErrorMessageToken} = require './error.message.token'
{InfoMessageToken} = require './info.message.token'
{LoginAckToken} = require './loginack.token'
{Packet} = require './packet'
{ReturnStatusToken} = require './returnstatus.token'
{RowToken} = require './row.token'

###*
Packet for TokenStream (0x04)

@spec 2.2.4.2
###
class exports.TokenStreamPacket extends Packet

  @type: 0x04
  @name: 'TokenStream'

  constructor: ->
  	@type = 0x04
  	@name = 'TokenStream'

  _getTokenFromType: (type) ->
  	switch type
      when ColMetaDataToken.type then new ColMetaDataToken
      when DoneToken.type, DoneToken.type2, DoneToken.type3 then new DoneToken
      when EnvChangeToken.type then new EnvChangeToken
      when ErrorMessageToken.type then new ErrorMessageToken
      when InfoMessageToken.type then new InfoMessageToken
      when LoginAckToken.type then new LoginAckToken
      when ReturnStatusToken.type then new ReturnStatusToken
      when RowToken.type then new RowToken
      else throw new Error 'Unrecognized type: ' + type 

  nextToken: (stream, context) ->
    type = stream.readByte()
    if context.logDebug then console.log 'Retrieved token type: ', type
    token = @_getTokenFromType type
    token.fromBuffer stream, context
    if context.logDebug then console.log 'Retrieved token: ', token
    token