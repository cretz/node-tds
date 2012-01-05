var TdsConstants, Token,
  __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

TdsConstants = require('./tds-constants').TdsConstants;

Token = require('./token').Token;

/**
Token for DONE (0xFD), DONEINPROC (0xFD), and DONEPROC (0xFE)

@spec 2.2.7.5
@spec 2.2.7.6
@spec 2.2.7.7
*/

exports.DoneToken = (function(_super) {

  __extends(DoneToken, _super);

  DoneToken.type = 0xFD;

  DoneToken.type2 = 0xFF;

  DoneToken.type3 = 0xFE;

  DoneToken.name = 'DONE';

  function DoneToken() {
    var _this = this;
    this.type = 0xFD;
    this.name = 'DONE';
    this.handlerFunction = 'done';
    this.__defineGetter__('hasMore', function() {
      return _this.status & 0x01 !== 0;
    });
    this.__defineGetter__('isError', function() {
      return _this.status & 0x02 !== 0;
    });
    this.__defineGetter__('hasRowCount', function() {
      return _this.status & 0x10 !== 0;
    });
    this.__defineGetter__('isCanceled', function() {
      return _this.status & 0x20 !== 0;
    });
    this.__defineGetter__('isCancelled', function() {
      return _this.status & 0x20 !== 0;
    });
    this.__defineGetter__('isFatal', function() {
      return _this.status & 0x100 !== 0;
    });
  }

  DoneToken.prototype.fromBuffer = function(stream, context) {
    this.status = stream.readUInt16LE();
    this.currentCommand = stream.readUInt16LE();
    if (context.tdsVersion >= TdsConstants.versionsByVersion['7.2']) {
      return this.rowCount = [stream.readUInt32LE(), stream.readUInt32LE()];
    } else {
      return this.rowCount = stream.readInt32LE();
    }
  };

  return DoneToken;

})(Token);
