var Packet,
  __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

Packet = require('./packet').Packet;

/**
Packet for RPCRequest (0x03)

@spec 2.2.6.5
*/

exports.RpcRequestPacket = (function(_super) {

  __extends(RpcRequestPacket, _super);

  RpcRequestPacket.type = 0x03;

  RpcRequestPacket.name = 'RPCRequest';

  function RpcRequestPacket() {
    this.type = 0x03;
    this.name = 'RPCRequest';
  }

  RpcRequestPacket.prototype.toBuffer = function(builder, context) {};

  return RpcRequestPacket;

})(Packet);
