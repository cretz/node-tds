var Token,
  __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

Token = require('./token').Token;

/**
Token for ORDERBY (0xA9)

@spec 2.2.7.14
*/

exports.OrderByToken = (function(_super) {

  __extends(OrderByToken, _super);

  OrderByToken.type = 0xA9;

  OrderByToken.name = 'ORDERBY';

  function OrderByToken() {
    this.type = 0xA9;
    this.name = 'ORDERBY';
    this.handlerFunction = 'orderby';
  }

  OrderByToken.prototype.fromBuffer = function(stream, context) {
    this.length = stream.readUInt16LE();
    return stream.skip(this.length);
  };

  return OrderByToken;

})(Token);
