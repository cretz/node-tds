var MessageToken;
var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

MessageToken = require('./message.token').MessageToken;

exports.InfoMessageToken = (function() {

  __extends(InfoMessageToken, MessageToken);

  InfoMessageToken.type = 0xAB;

  InfoMessageToken.name = 'INFO';

  function InfoMessageToken() {
    this.type = 0xAB;
    this.name = 'INFO';
  }

  return InfoMessageToken;

})();
