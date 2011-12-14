var Packet;
var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

Packet = require('./packet').Packet;

exports.DonePacket = (function() {

  __extends(DonePacket, Packet);

  DonePacket.type = 0xFD;

  DonePacket.name = 'DONE';

  function DonePacket() {
    this.type = 0xFD;
    this.name = 'DONE';
  }

  DonePacket.prototype.fromBuffer = function(stream, context) {
    this.status = stream.readUInt16LE();
    this.currentCommand = stream.readUInt16LE();
    return this.rowCount = [stream.readUInt32LE(), stream.readUInt32LE()];
  };

  return DonePacket;

})();
