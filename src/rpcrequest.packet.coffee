{Packet} = require './packet'

class exports.RpcRequestPacket extends Packet
  
  @type: 0x03
  @name: 'RPCRequest'
  
  constructor: ->
  	@type = 0x03
  	@name = 'RPCRequest'

  toBuffer: (builder, context) ->
    #TODO
