var TdsUtils, Token;
var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

TdsUtils = require('./tds-utils').TdsUtils;

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
    this.columns = context.columns;
    this.columnsByName = context.columnsByName;
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

  RowToken.prototype.getColumn = function(column) {
    if (typeof column === string) {
      return this.columnsByName[column];
    } else {
      return this.columns[column];
    }
  };

  RowToken.prototype.getValue = function(column) {
    var col, val;
    col = this.getColumn(column);
    if (!(col != null)) throw new Error('Column ' + column + ' not found');
    val = this.values[col.index];
    switch (col.type.name) {
      case 'Null':
        return null;
      case 'Bit':
      case 'TinyInt':
        if (val.length === 0) {
          return null;
        } else {
          return val.readUInt8(0);
        }
        break;
      case 'SmallInt':
        if (val.length === 0) {
          return null;
        } else {
          return val.readUInt16LE(0);
        }
        break;
      case 'Int':
        if (val.length === 0) {
          return null;
        } else {
          return val.readUInt32LE(0);
        }
        break;
      case 'BigInt':
        if (val.length === 0) {
          return null;
        } else {
          return TdsUtils.bigIntBufferToString(val);
        }
        break;
      case 'Char':
      case 'VarChar':
        if (col.length === -1) {
          return null;
        } else {
          return val.toString('ascii');
        }
        break;
      case 'NChar':
      case 'NVarChar':
        if (col.length === -1) {
          return null;
        } else {
          return val.toString('ucs2');
        }
        break;
      case 'Binary':
      case 'VarBinary':
        if (col.length === -1) {
          return null;
        } else {
          return val;
        }
        break;
      case 'Real':
        if (val.length === 0) {
          return null;
        } else {
          return val.readFloatLE(0);
        }
        break;
      case 'Float':
        if (val.length === 0) {
          return null;
        } else {
          return val.readDoubleLE(0);
        }
        break;
      case 'UniqueIdentifier':
        if (val.length === 0) {
          return null;
        } else {
          return val;
        }
        break;
      case 'SmallDateTime':
        if (val.length === 0) {
          return null;
        } else {
          return this._readSmallDateTime(val);
        }
        break;
      case 'DateTime':
        if (val.length === 0) {
          return null;
        } else {
          return this._readDateTime(val);
        }
    }
  };

  RowToken.prototype._readSmallDateTime = function(buffer) {
    var date;
    date = new Date(1900, 0, 1);
    date.setDate(date.getDate() + buffer.readUInt16LE());
    date.setMinutes(date.getMinutes() + buffer.readUInt16LE());
    return date;
  };

  RowToken.prototype._readDateTime = function(buffer) {
    var date;
    date = new Date(1900, 0, 1);
    date.setDate(value.getDate() + buffer.readInt32LE());
    date.setMilliseconds(value.getMilliseconds() + (buffer.readInt32LE() * (10 / 3.0)));
    return date;
  };

  return RowToken;

})();
