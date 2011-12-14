var Packet;
var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

Packet = require('./packet').Packet;

exports.RowPacket = (function() {

  __extends(RowPacket, Packet);

  RowPacket.type = 0xD1;

  RowPacket.name = 'ROW';

  function RowPacket() {
    this.type = 0xD1;
    this.name = 'ROW';
  }

  RowPacket.prototype.fromBuffer = function(stream, context) {
    var column, _i, _len, _ref, _results;
    this.values = new Array(context.columns.length);
    _ref = context.columns;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      column = _ref[_i];
      _results.push(this.values.push(stream.readBuffer(column.length)));
    }
    return _results;
  };

  return RowPacket;

})();
