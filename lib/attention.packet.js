var Packet,
  __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

Packet = require('./packet').Packet;

/**
Packet for ATTENTION (0x06). This is sent to cancel
a query.

@spec 2.2.1.6
*/

exports.AttentionPacket = (function(_super) {

  __extends(AttentionPacket, _super);

  AttentionPacket.type = 0x06;

  AttentionPacket.name = 'ATTENTION';

  function AttentionPacket() {
    this.type = 0x06;
    this.name = 'ATTENTION';
  }

  AttentionPacket.prototype.toBuffer = function(builder, context) {
    return this.insertPacketHeader(builder, context);
  };

  return AttentionPacket;

})(Packet);
