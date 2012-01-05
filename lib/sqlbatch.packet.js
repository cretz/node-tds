var Packet,
  __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

Packet = require('./packet').Packet;

/**
Packet for SQLBatch (0x01)

@spec 2.2.6.6
*/

exports.SqlBatchPacket = (function(_super) {

  __extends(SqlBatchPacket, _super);

  SqlBatchPacket.type = 0x01;

  SqlBatchPacket.name = 'SQLBatch';

  function SqlBatchPacket() {
    this.type = 0x01;
    this.name = 'SQLBatch';
  }

  SqlBatchPacket.prototype.toBuffer = function(builder, context) {
    var txHeader;
    if (this.sqlText == null) this.sqlText = '';
    builder.appendUcs2String(this.sqlText);
    txHeader = this.buildTransactionDescriptorAllHeader(0, 1);
    this.insertAllHeaders(builder, context, [txHeader]);
    this.insertPacketHeader(builder, context);
    return builder;
  };

  return SqlBatchPacket;

})(Packet);
