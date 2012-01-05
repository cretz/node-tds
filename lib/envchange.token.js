var TdsConstants, Token,
  __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

TdsConstants = require('./tds-constants').TdsConstants;

Token = require('./token').Token;

/**
Token for ENVCHANGE (0xE3)

@spec 2.2.7.8
*/

exports.EnvChangeToken = (function(_super) {

  __extends(EnvChangeToken, _super);

  EnvChangeToken.type = 0xE3;

  EnvChangeToken.name = 'ENVCHANGE';

  function EnvChangeToken() {
    this.type = 0xE3;
    this.name = 'ENVCHANGE';
    this.handlerFunction = 'envchange';
  }

  EnvChangeToken.prototype._readValue = function(typedef, stream, context) {
    if (!(typedef != null)) {
      stream.skip(1);
      return null;
    } else if (typedef === '2byteskip') {
      stream.skip(2);
      return null;
    } else {
      switch (typedef) {
        case 'string':
          return stream.readUcs2String(stream.readByte());
        case 'bytes':
          return stream.readBuffer(stream.readByte());
        case 'byte':
          return stream.readByte();
        case 'longbytes':
          return stream.readBuffer(stream.readUInt32LE());
        case 'shortbytes':
          return stream.readBuffer(stream.readUInt16LE());
        default:
          throw new Error('Unrecognized typedef: ' + typedef);
      }
    }
  };

  EnvChangeToken.prototype.fromBuffer = function(stream, context) {
    var typedef;
    this.length = stream.readUInt16LE();
    this.changeType = stream.readByte();
    stream.assertBytesAvailable(this.length);
    typedef = TdsConstants.envChangeTypesByNumber[this.changeType];
    if (!(typedef != null)) {
      throw new Error('Unrecognized envchange type: ' + this.changeType);
    }
    this.newValue = this._readValue(typedef.newValue, stream, context);
    return this.oldValue = this._readValue(typedef.oldValue, stream, context);
  };

  return EnvChangeToken;

})(Token);
