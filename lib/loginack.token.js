var Token,
  __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

Token = require('./token').Token;

/**
Token for LOGINACK (0xAD)

@spec 2.2.7.11
*/

exports.LoginAckToken = (function(_super) {

  __extends(LoginAckToken, _super);

  LoginAckToken.type = 0xAD;

  LoginAckToken.name = 'LOGINACK';

  function LoginAckToken() {
    this.type = 0xAD;
    this.name = 'LOGINACK';
    this.handlerFunction = 'loginack';
  }

  LoginAckToken.prototype.fromBuffer = function(stream, context) {
    var len;
    this.length = stream.readUInt16LE();
    stream.assertBytesAvailable(this.length);
    this.interface = stream.readByte();
    this.tdsVersion = stream.readUInt32LE();
    len = stream.readByte();
    if (context.logDebug) console.log('Reading progName of length', len);
    this.progName = stream.readUcs2String(len);
    this.majorVer = stream.readByte();
    this.minorVer = stream.readByte();
    this.buildNum = stream.readByte() << 8;
    return this.buildNum += stream.readByte();
  };

  return LoginAckToken;

})(Token);
