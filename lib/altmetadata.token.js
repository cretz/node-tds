var AltMetaDataToken, Token,
  __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

Token = require('./token').Token;

/**
Token for ALTMETADATA (0x88)

@spec 2.2.7.1
*/

AltMetaDataToken = (function(_super) {

  __extends(AltMetaDataToken, _super);

  AltMetaDataToken.type = 0x88;

  AltMetaDataToken.name = 'ALTMETADATA';

  function AltMetaDataToken() {
    this.type = 0x88;
    this.name = 'ALTMETADATA';
    this.handlerFunction = 'altmetadata';
  }

  AltMetaDataToken.prototype.fromBuffer = function(stream, context) {};

  return AltMetaDataToken;

})(Token);
