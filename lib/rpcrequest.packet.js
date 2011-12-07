var Packet;
var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

Packet = require('./packet').Packet;

exports.RpcRequestPacket = (function() {

  __extends(RpcRequestPacket, Packet);

  function RpcRequestPacket() {
    RpcRequestPacket.__super__.constructor.apply(this, arguments);
  }

  RpcRequestPacket.type = 0x03;

  RpcRequestPacket.name = 'RPCPacket';

  RpcRequestPacket.prototype.type = 0x03;

  RpcRequestPacket.prototype.name = 'RPCPacket';

  RpcRequestPacket.prototype.procedureId = null;

  RpcRequestPacket.prototype.procedureName = null;

  RpcRequestPacket.prototype.optionFlags = null;

  RpcRequestPacket.prototype.parameters = null;

  RpcRequestPacket.prototype.toBuffer = function(builder, context) {};

  return RpcRequestPacket;

})();
