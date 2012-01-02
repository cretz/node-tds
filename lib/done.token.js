var TdsConstants, Token;
var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

TdsConstants = require('./tds-constants').TdsConstants;

Token = require('./token').Token;

exports.DoneToken = (function() {

  __extends(DoneToken, Token);

  DoneToken.type = 0xFD;

  DoneToken.name = 'DONE';

  function DoneToken() {
    this.type = 0xFD;
    this.name = 'DONE';
    this.handlerFunction = 'done';
    this.__defineGetter__('hasMore', function() {
      return this.status & 0x0001;
    });
    this.__defineGetter__('isError', function() {
      return this.status & 0x0002;
    });
    this.__defineGetter__('hasRowCount', function() {
      return this.status & 0x0010;
    });
    this.__defineGetter__('isCancelled', function() {
      return this.status & 0x0020;
    });
    this.__defineGetter__('isFatal', function() {
      return this.status & 0x0100;
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

})();
