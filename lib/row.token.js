var TdsUtils, Token,
  __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

TdsUtils = require('./tds-utils').TdsUtils;

Token = require('./token').Token;

/**
Token for ROW (0xD1)

@spec 2.2.7.17
*/

exports.RowToken = (function(_super) {

  __extends(RowToken, _super);

  RowToken.type = 0xD1;

  RowToken.name = 'ROW';

  function RowToken() {
    this.type = 0xD1;
    this.name = 'ROW';
    this.handlerFunction = 'row';
  }

  RowToken.prototype.fromBuffer = function(stream, context) {
    var column, index, val, _len, _ref, _results;
    this.metadata = context.colmetadata;
    this.values = new Array(this.metadata.columns.length);
    _ref = this.metadata.columns;
    _results = [];
    for (index = 0, _len = _ref.length; index < _len; index++) {
      column = _ref[index];
      val = {};
      switch (column.lengthType) {
        case 'int32LE':
          val.length = stream.readInt32LE();
          break;
        case 'uint16LE':
          val.length = stream.readUInt16LE();
          break;
        case 'uint8':
          val.length = stream.readByte();
          break;
        default:
          val.length = column.length;
      }
      if (val.length === 0xFFFF) val.length = -1;
      if (val.length === 0 && column.type.emptyPossible) {
        val.buffer = new Buffer(0);
      } else if (val.length > 0) {
        val.buffer = stream.readBuffer(val.length);
      }
      _results.push(this.values[index] = val);
    }
    return _results;
  };

  RowToken.prototype.isNull = function(column) {
    var col;
    col = this.metadata.getColumn(column);
    if (!(col != null)) throw new Error('Column ' + column + ' not found');
    if (col.type.emptyPossible) {
      return this.values[col.index].length === -1;
    } else {
      return this.values[col.index] === 0;
    }
  };

  RowToken.prototype.getValueLength = function(column) {
    var col;
    col = this.metadata.getColumn(column);
    if (!(col != null)) throw new Error('Column ' + column + ' not found');
    return this.values[col.index].length;
  };

  RowToken.prototype.getValue = function(column) {
    var col, val;
    col = this.metadata.getColumn(column);
    if (!(col != null)) throw new Error('Column ' + column + ' not found');
    val = this.values[col.index];
    switch (col.type.sqlType) {
      case 'Null':
        return null;
      case 'Bit':
      case 'TinyInt':
        if (val.length === 0) {
          return null;
        } else {
          return val.buffer.readInt8(0);
        }
        break;
      case 'SmallInt':
        if (val.length === 0) {
          return null;
        } else {
          return val.buffer.readInt16LE(0);
        }
        break;
      case 'Int':
        if (val.length === 0) {
          return null;
        } else {
          return val.buffer.readInt32LE(0);
        }
        break;
      case 'BigInt':
        if (val.length === 0) {
          return null;
        } else {
          return TdsUtils.bigIntBufferToString(val.buffer);
        }
        break;
      case 'Char':
      case 'VarChar':
        if (val.length === -1) {
          return null;
        } else {
          return val.buffer.toString('ascii', 0, val.length);
        }
        break;
      case 'NChar':
      case 'NVarChar':
        if (val.length === -1) {
          return null;
        } else {
          return val.buffer.toString('ucs2', 0, val.length * 2);
        }
        break;
      case 'Binary':
      case 'VarBinary':
        if (col.length === -1) {
          return null;
        } else {
          return val.buffer;
        }
        break;
      case 'Real':
        if (val.length === 0) {
          return null;
        } else {
          return val.buffer.readFloatLE(0);
        }
        break;
      case 'Float':
        if (val.length === 0) {
          return null;
        } else {
          return val.buffer.readDoubleLE(0);
        }
        break;
      case 'UniqueIdentifier':
        if (val.length === 0) {
          return null;
        } else {
          return val.buffer;
        }
        break;
      case 'SmallDateTime':
        if (val.length === 0) {
          return null;
        } else {
          return this._readSmallDateTime(val.buffer);
        }
        break;
      case 'DateTime':
        if (val.length === 0) {
          return null;
        } else {
          return this._readDateTime(val.buffer);
        }
        break;
      case 'Date':
        if (val.length === 0) {
          return null;
        } else {
          return this._readDate(val.buffer);
        }
        break;
      default:
        throw new Error('Unrecognized type ' + col.type.name);
    }
  };

  RowToken.prototype.getBuffer = function(column) {
    var col;
    col = this.metadata.getColumn(column);
    if (!(col != null)) throw new Error('Column ' + column + ' not found');
    return this.values[col.index].buffer;
  };

  RowToken.prototype.toObject = function() {
    var column, ret, _i, _len, _ref;
    ret = {};
    _ref = this.metadata.columns;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      column = _ref[_i];
      ret[column.name] = getValue(column.index);
    }
    return ret;
  };

  RowToken.prototype._readSmallDateTime = function(buffer) {
    var date;
    date = new Date(1900, 0, 1);
    date.setDate(date.getDate() + buffer.readUInt16LE(0));
    date.setMinutes(date.getMinutes() + buffer.readUInt16LE(2));
    return date;
  };

  RowToken.prototype._readDateTime = function(buffer) {
    var date;
    date = new Date(1900, 0, 1);
    date.setDate(date.getDate() + buffer.readInt32LE(0));
    date.setMilliseconds(date.getMilliseconds() + (buffer.readInt32LE(4) * (10 / 3.0)));
    return date;
  };

  RowToken.prototype._readDate = function(buffer) {
    throw new Error('Not implemented');
  };

  return RowToken;

})(Token);
