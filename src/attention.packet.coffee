{Packet} = require './packet'

###*
Packet for ATTENTION (0x06). This is sent to cancel
a query.

@spec 2.2.1.6
###
class exports.AttentionPacket extends Packet
  
  @type: 0x06
  @name: 'ATTENTION'

  constructor: ->
    @type = 0x06
    @name = 'ATTENTION'
  
  toBuffer: (builder, context) ->
    @insertPacketHeader builder, context
