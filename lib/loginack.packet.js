var Packet;
var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

Packet = require('./packet').Packet;

exports.LoginAckPacket = (function() {

  __extends(LoginAckPacket, Packet);

  function LoginAckPacket() {
    LoginAckPacket.__super__.constructor.apply(this, arguments);
  }

  LoginAckPacket.type = 0xAD;

  LoginAckPacket.name = 'LOGINACK';

  LoginAckPacket.prototype.type = 0xAD;

  LoginAckPacket.prototype.name = 'LOGINACK';

  LoginAckPacket.prototype.interface = 0;

  LoginAckPacket.prototype.tdsVersion = 0;

  LoginAckPacket.prototype.progName = '';

  LoginAckPacket.prototype.majorVer = 0;

  LoginAckPacket.prototype.minorVer = 0;

  LoginAckPacket.prototype.buildNum = 0;

  LoginAckPacket.prototype.fromBuffer = function(stream, context) {
    stream.assertBytesAvailable(stream.readUInt16LE());
    this.interface = stream.readByte();
    this.tdsVersion = stream.readUInt32LE();
    this.progName = stream.readUcs2String(stream.readByte() - 1);
    stream.skip(1);
    this.majorVer = stream.readByte();
    this.minorVer = stream.readByte();
    this.buildNum = stream.readByte() << 8;
    return this.buildNum = stream.readByte();
  };

  return LoginAckPacket;

})();
