class exports.Packet
  
  @retrieveHeader: (stream, context) ->
    ret =
      type: stream.readByte()
      status: stream.readByte()
      length: stream.readUInt16BE()
      processId: stream.readUInt16BE()
      packetId: stream.readByte()
      window: stream.readByte()
    if context.logDebug then console.log 'Retrieved header: ', ret
    # assert length
    stream.assertBytesAvailable ret.length - 8
    ret
  
  fromBuffer: (stream, context) -> throw new Error 'Unimplemented'
  
  toBuffer: (builder, context) -> throw new Error 'Unimplemented'
  
  insertPacketHeader: (builder, context, endOfMessage = true) ->
    # packet type
    builder.insertByte @type, 0
    # status
    builder.insertByte (if endOfMessage then 1 else 0), 1
    # length (current length + 5 for the more we're gonna add to the header)
    builder.insertUInt16BE builder.length + 6, 2
    # process id (always 0)
    builder.insertUInt16BE 0, 3
    # packet ID (ignored, setting to 1)
    builder.insertByte 1, 4
    # window (unused, always 0)
    builder.insertByte 0, 5
    # return
    builder
    
  buildTransactionDescriptorAllHeader: (transactionDescriptor, outstandingRequestCount)->
    type: 2
    transactionDescriptor: transactionDescriptor
    outstandingRequestCount: outstandingRequestCount
  
  insertAllHeaders: (builder, context, headers) ->
    offset = 0
    for header in headers
      switch header.type
        when 2
          builder.insertUInt32LE 12, offset
          offset += 4
          builder.insertUInt16LE header.type, offset
          offset += 2
          builder.insertUInt32LE header.transactionDescriptor % 0x100000000, offset
          offset += 4
          builder.insertUInt32LE header.transactionDescriptor / 0x100000000, offset
          offset += 4
          builder.insertUInt32LE header.outstandingRequestCount, offset
          offset += 4
        else throw new Error 'Unsupported all header type ' + header.type
    builder.insertUInt32LE builder.length, 0
    # return
    builder

  toString: ->
    ret = ''
    util = require 'util'
    for key, value of @
      if typeof value isnt 'function'
        if ret isnt '' then ret += ', '
        ret += key + ': ' + util.format value
    ret
