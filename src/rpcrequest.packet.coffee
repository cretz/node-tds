{Packet} = require './packet'

class exports.RpcRequestPacket extends Packet
  
  @type: 0x03
  
  @name: 'RPCPacket'
  
  procedureId: null
  
  procedureName: null
  
  optionFlags: null
  
  parameters: null
  
  toBuffer: (builder) ->
    
