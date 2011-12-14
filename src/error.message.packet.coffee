{MessagePacket} = require './message.packet'

class exports.ErrorMessagePacket extends MessagePacket
  
  @type: 0xAA
  @name: 'ERROR'

  constructor: ->
    @type = 0xAA
    @name = 'ERROR'
