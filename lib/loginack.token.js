var Token;
var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

Token = require('./token').Token;

exports.LoginAckToken = (function() {

  __extends(LoginAckToken, Token);

  LoginAckToken.type = 0xAD;

  LoginAckToken.name = 'LOGINACK';

  function LoginAckToken() {
    ({
      type: 0xAD,
      name: 'LOGINACK'
    });
  }

  LoginAckToken.prototype.fromBuffer = function(stream, context) {
    this.length = 2 + stream.readUInt16LE();
    stream.assertBytesAvailable(this.length - 2);
    this.interface = stream.readByte();
    this.tdsVersion = stream.readUInt32LE();
    this.progName = stream.readUcs2String(stream.readByte() - 1);
    stream.skip(1);
    this.majorVer = stream.readByte();
    this.minorVer = stream.readByte();
    this.buildNum = stream.readByte() << 8;
    return this.buildNum += stream.readByte();
  };

  return LoginAckToken;

})();
