{Packet} = require './packet'

class exports.SqlBatchPacket extends Packet
  
  @type: 0x01
  @name: 'SQLBatch'
  
  type: 0x01
  name: 'SQLBatch'
  
  sqlText: ''
  
  toBuffer: (builder) ->
    builder.appendUcs2String @sqlText
    txHeader = @buildTransactionDescriptorAllHeader 0, 1
    @insertAllHeaders builder, [txHeader]
    @insertPacketHeader builder
