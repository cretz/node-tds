var Packet;
var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

Packet = require('./packet').Packet;

exports.MessagePacket = (function() {

  __extends(MessagePacket, Packet);

  function MessagePacket() {
    MessagePacket.__super__.constructor.apply(this, arguments);
  }

  MessagePacket.prototype.number = null;

  MessagePacket.prototype.state = null;

  MessagePacket.prototype.severity = null;

  MessagePacket.prototype.text = null;

  MessagePacket.prototype.serverName = null;

  MessagePacket.prototype.procName = null;

  MessagePacket.prototype.lineNumber = null;

  MessagePacket.prototype.fromBuffer = function(stream, context) {
    var len, lineNumber, procName, text;
    len = stream.readUInt16LE();
    stream.assertBytesAvailable(len);
    this.number = stream.readInt32LE();
    this.state = stream.readByte();
    this.severity = stream.readByte();
    text = stream.readUcs2String(stream.readUInt16LE());
    procName = stream.readUcs2String(stream.readUInt16LE());
    return lineNumber = stream.readInt32LE();
  };

  return MessagePacket;

})();
