{Packet} = require './packet'

###*
Packet for RPCRequest (0x03)

@spec 2.2.6.5
###
class exports.RpcRequestPacket extends Packet
  
  @type: 0x03
  @name: 'RPCRequest'
  
  constructor: ->
  	@type = 0x03
  	@name = 'RPCRequest'

  toBuffer: (builder, context) ->
    #TODO
