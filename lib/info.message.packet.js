var MessagePacket;
var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

MessagePacket = require('./message.packet').MessagePacket;

exports.InfoMessagePacket = (function() {

  __extends(InfoMessagePacket, MessagePacket);

  function InfoMessagePacket() {
    InfoMessagePacket.__super__.constructor.apply(this, arguments);
  }

  InfoMessagePacket.type = 0xAB;

  InfoMessagePacket.name = 'INFO';

  InfoMessagePacket.prototype.type = 0xAB;

  InfoMessagePacket.prototype.name = 'INFO';

  return InfoMessagePacket;

})();
