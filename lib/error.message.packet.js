var MessagePacket;
var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

MessagePacket = require('./message.packet').MessagePacket;

exports.ErrorMessagePacket = (function() {

  __extends(ErrorMessagePacket, MessagePacket);

  function ErrorMessagePacket() {
    ErrorMessagePacket.__super__.constructor.apply(this, arguments);
  }

  ErrorMessagePacket.type = 0xAA;

  ErrorMessagePacket.name = 'ERROR';

  ErrorMessagePacket.prototype.type = 0xAA;

  ErrorMessagePacket.prototype.name = 'ERROR';

  return ErrorMessagePacket;

})();
