var Packet;
var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

Packet = require('./packet').Packet;

exports.LoginAckPacket = (function() {

  __extends(LoginAckPacket, Packet);

  LoginAckPacket.type = 0xAD;

  LoginAckPacket.name = 'LOGINACK';

  function LoginAckPacket() {
    ({
      type: 0xAD,
      name: 'LOGINACK'
    });
  }

  LoginAckPacket.prototype.fromBuffer = function(stream, context) {
    stream.assertBytesAvailable(stream.readUInt16LE());
    this.interface = stream.readByte();
    this.tdsVersion = stream.readUInt32LE();
    this.progName = stream.readUcs2String(stream.readByte() - 1);
    stream.skip(1);
    this.majorVer = stream.readByte();
    this.minorVer = stream.readByte();
    this.buildNum = stream.readByte() << 8;
    return this.buildNum += stream.readByte();
  };

  return LoginAckPacket;

})();
