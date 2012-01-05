/**
Common TDS utility functions
*/
exports.TdsUtils = (function() {

  function TdsUtils() {}

  TdsUtils.buildParameterDefinition = function(params, shouldAssert) {
    var key, parameterString, value;
    parameterString = '';
    for (key in params) {
      value = params[key];
      if (shouldAssert) {
        if (typeof key !== 'string' || typeof value.type !== 'string') {
          throw new Error('Unexpected param name or type name');
        }
        if ((value.size != null) && typeof value.size !== 'number') {
          throw new Error('Unexpected type for value size');
        }
        if ((value.scale != null) && typeof value.scale !== 'number') {
          throw new Error('Unexpected type for value scale');
        }
        if ((value.precision != null) && typeof value.precision !== 'number') {
          throw new Error('Unexpected type for value precision');
        }
        if (key.indexOf(',' !== -1 || value.indexOf(',' !== -1))) {
          throw new Error('Cannot have comma in parameter list');
        }
        if (key.indexOf('@' !== -1 || value.indexOf('@' !== -1))) {
          throw new Error('Cannot have at sign (@) in parameter list');
        }
        if (key.indexOf(' ' !== -1 || value.indexOf(' ' !== -1))) {
          throw new Error('Cannot have space in parameter list');
        }
        if (key.indexOf("'" !== -1 || value.indexOf("'" !== -1))) {
          throw new Error('Cannot have apostrophe in parameter list');
        }
      }
      if (parameterString !== '') parameterString += ',';
      parameterString += '@' + key + ' ' + value.type;
      if (value.size != null) {
        parameterString += '(' + value.size + ')';
      } else if ((value.scale != null) && (value.precision != null)) {
        parameterString += '(' + value.precision + ',' + value.scale + ')';
      }
      if (value.output) parameterString += ' OUTPUT';
    }
    return parameterString;
  };

  TdsUtils.buildParameterizedSql = function(params, paramValues) {
    var key, param, paramSql, value;
    paramSql = '';
    for (key in paramValues) {
      value = paramValues[key];
      param = params[key];
      if (!(param != null)) throw new Error('Undefined parameter ' + key);
      if (paramSql !== '') paramSql += ', ';
      paramSql += '@' + key + ' = ';
      switch (typeof value) {
        case 'string':
          if (param.type.toUpperCase() === 'BIGINT') {
            paramSql += value;
          } else {
            paramSql += "N'" + value.replace(/'/g, "''") + "'";
          }
          break;
        case 'number':
          paramSql += value;
          break;
        case 'boolean':
          paramSql += value ? 1 : 0;
          break;
        case 'object':
          if (!(value != null)) {
            paramSql += 'NULL';
          } else if (value instanceof Date) {
            paramSql += "'" + TdsUtils.formatDate(value, !param.timeOnly, !param.dateOnly) + "'";
          } else if (Buffer.isBuffer(value)) {
            paramSql += '0x' + value.toString('hex');
          } else {
            throw new Error('Unsupported parameter type: ' + typeof value);
          }
          break;
        default:
          throw new Error('Unsupported parameter type: ' + typeof value);
      }
    }
    return paramSql;
  };

  TdsUtils.formatDate = function(date, includeDate, includeTime) {
    var str;
    str = '';
    if (includeDate) {
      if (date.getFullYear() < 1000) str += '0';
      if (date.getFullYear() < 100) str += '0';
      if (date.getFullYear() < 10) str += '0';
      str += date.getFullYear() + '-';
      if (date.getMonth() < 9) str += '0';
      str += (date.getMonth() + 1) + '-';
      if (date.getDate() < 10) str += '0';
      str += date.getDate();
    }
    if (includeTime) {
      if (str !== '') str += ' ';
      if (date.getHours() < 10) str += '0';
      str += date.getHours() + ':';
      if (date.getMinutes() < 10) str += '0';
      str += date.getMinutes() + ':';
      if (date.getSeconds() < 10) str += '0';
      str += date.getSeconds() + '.';
      if (date.getMilliseconds() < 100) str += '0';
      if (date.getMilliseconds() < 10) str += '0';
      return str += date.getMilliseconds();
    }
  };

  TdsUtils.bigIntBufferToString = function(buffer) {
    var arr, invert, isZero, nextRemainder, result, sign, t;
    arr = Array.prototype.slice.call(buffer, 0, buffer.length);
    isZero = function(array) {
      var byte, _i, _len;
      for (_i = 0, _len = array.length; _i < _len; _i++) {
        byte = array[_i];
        if (byte !== 0) return false;
      }
      return true;
    };
    if (isZero(arr)) return '0';
    nextRemainder = function(array) {
      var index, remainder, s, _ref;
      remainder = 0;
      for (index = _ref = array.length - 1; index >= 0; index += -1) {
        s = (remainder * 256) + array[index];
        array[index] = Math.floor(s / 10);
        remainder = s % 10;
      }
      return remainder;
    };
    invert = function(array) {
      var byte, index, _len, _len2, _results;
      for (index = 0, _len = array.length; index < _len; index++) {
        byte = array[index];
        array[index] = array[index] ^ 0xFF;
      }
      _results = [];
      for (index = 0, _len2 = array.length; index < _len2; index++) {
        byte = array[index];
        array[index] = array[index] + 1;
        if (array[index] > 255) {
          _results.push(array[index] = 0);
        } else {
          break;
        }
      }
      return _results;
    };
    if (arr[arr.length - 1] & 0x80) {
      sign = '-';
      invert(arr);
    } else {
      sign = '';
    }
    result = '';
    while (!isZero(arr)) {
      t = nextRemainder(arr);
      result = t + result;
    }
    return sign + result;
  };

  return TdsUtils;

})();
