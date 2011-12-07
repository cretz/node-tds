var Packet;
var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

Packet = require('./packet').Packet;

exports.DonePacket = (function() {

  __extends(DonePacket, Packet);

  function DonePacket() {
    DonePacket.__super__.constructor.apply(this, arguments);
  }

  DonePacket.type = 0xFD;

  DonePacket.name = 'DONE';

  DonePacket.prototype.type = 0xFD;

  DonePacket.prototype.name = 'DONE';

  DonePacket.prototype.status = null;

  DonePacket.prototype.currentCommand = null;

  DonePacket.prototype.rowCount = null;

  DonePacket.prototype.fromBuffer = function(stream, context) {
    this.status = stream.readUInt16LE();
    this.currentCommand = stream.readUInt16LE();
    return this.rowCount = [stream.readUInt32LE(), stream.readUInt32LE()];
  };

  return DonePacket;

})();
