{MessagePacket} = require './message.packet'

class exports.InfoMessagePacket extends MessagePacket
  
  @type: 0xAB
  @name: 'INFO'

  constructor: ->
  	@type = 0xAB
  	@name = 'INFO'
