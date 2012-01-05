var TdsConstants, Token,
  __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

TdsConstants = require('./tds-constants').TdsConstants;

Token = require('./token').Token;

/**
Base token for error and info message tokens
*/

exports.MessageToken = (function(_super) {

  __extends(MessageToken, _super);

  function MessageToken() {
    MessageToken.__super__.constructor.apply(this, arguments);
  }

  MessageToken.prototype.fromBuffer = function(stream, context) {
    this.length = stream.readUInt16LE();
    stream.assertBytesAvailable(this.length);
    this.number = stream.readInt32LE();
    this.state = stream.readByte();
    this.severity = stream.readByte();
    this.text = stream.readUcs2String(stream.readUInt16LE());
    if (context.logDebug) console.log('Read: %s', this.text);
    this.serverName = stream.readUcs2String(stream.readByte());
    this.procName = stream.readUcs2String(stream.readByte());
    if (context.tdsVersion >= TdsConstants.versionsByVersion['7.2']) {
      return this.lineNumber = stream.readInt32LE();
    } else {
      return this.lineNumber = stream.readUInt16LE();
    }
  };

  return MessageToken;

})(Token);
