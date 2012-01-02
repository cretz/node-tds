var TdsConstants, Token;
var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

Token = require('./token').Token;

TdsConstants = require('./tds-constants').TdsConstants;

exports.ColMetaDataToken = (function() {

  __extends(ColMetaDataToken, Token);

  ColMetaDataToken.type = 0x81;

  ColMetaDataToken.name = 'COLMETADATA';

  function ColMetaDataToken() {
    this.type = 0x81;
    this.name = 'COLMETADATA';
    this.handlerFunction = 'colmetadata';
  }

  ColMetaDataToken.prototype.fromBuffer = function(stream, context) {
    var column, i, len, _ref, _results;
    len = stream.readUInt16LE();
    this.columns = new Array(len);
    this.columnsByName = {};
    if (len !== 0xFFFF) {
      _results = [];
      for (i = 0, _ref = len - 1; 0 <= _ref ? i <= _ref : i >= _ref; 0 <= _ref ? i++ : i--) {
        this.columns[i] = column = {
          index: i,
          userType: stream.readUInt16LE(),
          flags: stream.readUInt16LE(),
          type: stream.readByte()
        };
        column.type = TdsConstants.dataTypesByType[column.type];
        if (!(column.type != null)) {
          throw new Error('Unrecognized type 0x' + column.type.toString(16));
        }
        column.isNullable = column.flags & 0x01 !== 0;
        column.isCaseSensitive = column.flags & 0x02 !== 0;
        column.isIdentity = column.flags & 0x10 !== 0;
        column.isWriteable = column.flags & 0x0C !== 0;
        if (!(column.type.length != null)) {
          if (column.type.hasScaleWithoutLength) {
            column.length = column.scale = stream.readByte();
          } else {
            switch (column.type.lengthType) {
              case 'int32LE':
                column.length = stream.readInt32LE();
                break;
              case 'uint16LE':
                column.length = stream.readUInt16LE();
                break;
              default:
                column.length = stream.readByte();
            }
          }
          if (column.type.lengthSubstitute != null) {
            column.type = TdsConstants.dataTypesByType[column.type.lengthSubstitute[column.length]];
            if (!(column.type != null)) {
              throw new Error('Unable to find length substitute ' + column.length);
            }
          }
          if (column.type.hasCollation) {
            column.collation = stream.readBytes(5);
          } else if (column.type.hasScaleAndPrecision) {
            column.scale = stream.readByte();
            column.precision = stream.readByte();
          }
        } else {
          column.length = column.type.length;
        }
        if (column.length === 0xFFFF) column.length = -1;
        if (column.type.hasTableName) {
          column.tableName = stream.readUcs2String(stream.readUInt16LE());
        }
        column.name = stream.readUcs2String(stream.readByte());
        _results.push(this.columnsByName[column.name] = column);
      }
      return _results;
    }
  };

  return ColMetaDataToken;

})();
