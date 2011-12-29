var Token;
var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

Token = require('./token').Token;

exports.RowToken = (function() {

  __extends(RowToken, Token);

  RowToken.type = 0xD1;

  RowToken.name = 'ROW';

  function RowToken() {
    this.type = 0xD1;
    this.name = 'ROW';
    this.handlerFunction = 'row';
  }

  RowToken.prototype.fromBuffer = function(stream, context) {
    var column, index, _i, _len, _ref, _results;
    this.values = new Array(context.columns.length);
    index = -1;
    _ref = context.columns;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      column = _ref[_i];
      _results.push(this.values[++index] = stream.readBuffer(column.length));
    }
    return _results;
  };

  return RowToken;

})();
