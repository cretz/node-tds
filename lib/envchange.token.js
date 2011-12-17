var Token;
var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

Token = require('./token').Token;

exports.EnvChangeToken = (function() {

  __extends(EnvChangeToken, Token);

  EnvChangeToken.type = 0xE3;

  EnvChangeToken.name = 'ENVCHANGE';

  function EnvChangeToken() {
    this.type = 0xE3;
    this.name = 'ENVCHANGE';
  }

  EnvChangeToken.prototype.fromBuffer = function(stream, context) {
    this.length = stream.readUInt16LE();
    return stream.skip(this.length);
  };

  return EnvChangeToken;

})();
