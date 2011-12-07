{Packet} = require './packet'

class exports.SqlBatchPacket extends Packet
  
  @type: 0x01
  @name: 'SQLBatch'
  
  type: 0x01
  name: 'SQLBatch'
  
  sqlText: ''
  
  toBuffer: (builder, context) ->
    builder.appendUcs2String @sqlText
    txHeader = @buildTransactionDescriptorAllHeader 0, 1
    @insertAllHeaders builder, context [txHeader]
    @insertPacketHeader builder, context
