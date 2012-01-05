var MessageToken,
  __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

MessageToken = require('./message.token').MessageToken;

/**
Token for ERROR (0xAA)

@spec 2.2.7.9
*/

exports.ErrorMessageToken = (function(_super) {

  __extends(ErrorMessageToken, _super);

  ErrorMessageToken.type = 0xAA;

  ErrorMessageToken.name = 'ERROR';

  function ErrorMessageToken() {
    this.type = 0xAA;
    this.name = 'ERROR';
    this.error = true;
    this.handlerFunction = 'message';
  }

  return ErrorMessageToken;

})(MessageToken);
