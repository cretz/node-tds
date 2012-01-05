var MessageToken,
  __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

MessageToken = require('./message.token').MessageToken;

/**
Token for INFO (0xAB)

@spec 2.2.7.10
*/

exports.InfoMessageToken = (function(_super) {

  __extends(InfoMessageToken, _super);

  InfoMessageToken.type = 0xAB;

  InfoMessageToken.name = 'INFO';

  function InfoMessageToken() {
    this.type = 0xAB;
    this.name = 'INFO';
    this.error = false;
    this.handlerFunction = 'message';
  }

  return InfoMessageToken;

})(MessageToken);
