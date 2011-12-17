var MessageToken;
var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

MessageToken = require('./message.token').MessageToken;

exports.ErrorMessageToken = (function() {

  __extends(ErrorMessageToken, MessageToken);

  ErrorMessageToken.type = 0xAA;

  ErrorMessageToken.name = 'ERROR';

  function ErrorMessageToken() {
    this.type = 0xAA;
    this.name = 'ERROR';
  }

  return ErrorMessageToken;

})();
