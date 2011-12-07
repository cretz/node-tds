var Packet;
var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

Packet = require('./packet').Packet;

exports.SqlBatchPacket = (function() {

  __extends(SqlBatchPacket, Packet);

  function SqlBatchPacket() {
    SqlBatchPacket.__super__.constructor.apply(this, arguments);
  }

  SqlBatchPacket.type = 0x01;

  SqlBatchPacket.name = 'SQLBatch';

  SqlBatchPacket.prototype.type = 0x01;

  SqlBatchPacket.prototype.name = 'SQLBatch';

  SqlBatchPacket.prototype.sqlText = '';

  SqlBatchPacket.prototype.toBuffer = function(builder, context) {
    var txHeader;
    builder.appendUcs2String(this.sqlText);
    txHeader = this.buildTransactionDescriptorAllHeader(0, 1);
    this.insertAllHeaders(builder, context([txHeader]));
    return this.insertPacketHeader(builder, context);
  };

  return SqlBatchPacket;

})();
