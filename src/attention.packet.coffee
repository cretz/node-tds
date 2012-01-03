{Packet} = require './packet'

class exports.AttentionPacket extends Packet
  
  @type: 0x06
  @name: 'ATTENTION'

  constructor: ->
    @type = 0x06
    @name = 'ATTENTION'
  
  toBuffer: (builder, context) ->
    @insertPacketHeader builder, context
