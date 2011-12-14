{Packet} = require './packet'

class exports.RpcRequestPacket extends Packet
  
  @type: 0x03
  @name: 'RPCPacket'
  
  constructor: ->
  	@type = 0x03
  	@name = 'RPCPacket'

  toBuffer: (builder, context) ->
    #TODO
