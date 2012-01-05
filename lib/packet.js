/**
Base class for all TDS packets
*/
exports.Packet = (function() {

  function Packet() {}

  Packet.retrieveHeader = function(stream, context) {
    var ret;
    ret = {
      type: stream.readByte(),
      status: stream.readByte(),
      length: stream.readUInt16BE(),
      processId: stream.readUInt16BE(),
      packetId: stream.readByte(),
      window: stream.readByte()
    };
    if (context.logDebug) console.log('Retrieved header: ', ret);
    return ret;
  };

  Packet.prototype.fromBuffer = function(stream, context) {
    throw new Error('Unimplemented');
  };

  Packet.prototype.toBuffer = function(builder, context) {
    throw new Error('Unimplemented');
  };

  Packet.prototype.insertPacketHeader = function(builder, context, endOfMessage) {
    if (endOfMessage == null) endOfMessage = true;
    if (context.logDebug) console.log('Inserting header for type: ', this.type);
    builder.insertByte(this.type, 0);
    builder.insertByte((endOfMessage ? 1 : 0), 1);
    builder.insertUInt16BE(builder.length + 6, 2);
    builder.insertUInt16BE(0, 3);
    builder.insertByte(1, 4);
    builder.insertByte(0, 5);
    return builder;
  };

  Packet.prototype.buildTransactionDescriptorAllHeader = function(transactionDescriptor, outstandingRequestCount) {
    return {
      type: 2,
      transactionDescriptor: transactionDescriptor,
      outstandingRequestCount: outstandingRequestCount
    };
  };

  Packet.prototype.insertAllHeaders = function(builder, context, headers) {
    var header, length, offset, _i, _len;
    offset = 0;
    length = 0;
    for (_i = 0, _len = headers.length; _i < _len; _i++) {
      header = headers[_i];
      switch (header.type) {
        case 2:
          length += 12;
          builder.insertUInt32LE(12, offset);
          offset += 4;
          builder.insertUInt16LE(header.type, offset);
          offset += 2;
          builder.insertUInt32LE(header.transactionDescriptor % 0x100000000, offset);
          offset += 4;
          builder.insertUInt32LE(header.transactionDescriptor / 0x100000000, offset);
          offset += 4;
          builder.insertUInt32LE(header.outstandingRequestCount, offset);
          offset += 4;
          break;
        default:
          throw new Error('Unsupported all header type ' + header.type);
      }
    }
    return builder.insertUInt32LE(length + 4, 0);
  };

  Packet.prototype.toString = function() {
    var key, ret, util, value;
    ret = '';
    util = require('util');
    for (key in this) {
      value = this[key];
      if (typeof value !== 'function') {
        if (ret !== '') ret += ', ';
        ret += key + ': ' + util.format(value);
      }
    }
    return ret;
  };

  return Packet;

})();
