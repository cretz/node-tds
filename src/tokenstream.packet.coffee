{ColMetaDataToken} = require './colmetadata.token'
{DoneToken} = require './done.token'
{EnvChangeToken} = require './envchange.token'
{ErrorMessageToken} = require './error.message.token'
{InfoMessageToken} = require './info.message.token'
{LoginAckToken} = require './loginack.token'
{OrderByToken} = require './orderby.token'
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

  _getTokenFromType: (type, context) ->
    switch type
      when ColMetaDataToken.type then new ColMetaDataToken
      when DoneToken.type, DoneToken.type2, DoneToken.type3 then new DoneToken
      when EnvChangeToken.type then new EnvChangeToken
      when ErrorMessageToken.type then new ErrorMessageToken
      when InfoMessageToken.type then new InfoMessageToken
      when LoginAckToken.type then new LoginAckToken
      when OrderByToken.type then new OrderByToken
      when ReturnStatusToken.type then new ReturnStatusToken
      when RowToken.type then new RowToken
      else 
        context.debug 'Unrecognized type: ' + type 
        throw new Error 'Unrecognized type: ' + type 

  nextToken: (stream, context) ->
    type = stream.readByte()
    context.debug 'Retrieved token type: ', type
    token = @_getTokenFromType type, context
    token.fromBuffer stream, context
    context.debug 'Retrieved token: ', token
    token