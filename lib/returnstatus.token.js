var Token,
  __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

Token = require('./token').Token;

/**
Token for RETURNSTATUS (0x79)

@spec 2.2.7.15
*/

exports.ReturnStatusToken = (function(_super) {

  __extends(ReturnStatusToken, _super);

  ReturnStatusToken.type = 0x79;

  ReturnStatusToken.name = 'RETURNSTATUS';

  function ReturnStatusToken() {
    this.type = 0x79;
    this.name = 'RETURNSTATUS';
    this.handlerFunction = 'returnstatus';
  }

  ReturnStatusToken.prototype.fromBuffer = function(stream, context) {
    return this.value = stream.readInt32LE();
  };

  return ReturnStatusToken;

})(Token);
