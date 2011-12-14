{Packet} = require './packet'

class exports.DonePacket extends Packet
  
  @type: 0xFD
  @name: 'DONE'
  
  constructor: ->
    @type = 0xFD
    @name = 'DONE'
  
  fromBuffer: (stream, context) ->
    @status = stream.readUInt16LE()
    @currentCommand = stream.readUInt16LE()
    @rowCount = [stream.readUInt32LE(), stream.readUInt32LE()]
