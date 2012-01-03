
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

  TdsUtils.buildParameterizedSql = function(sql, params, paramValues) {
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
          paramSql += "N'" + value.replace(/'/g, "''") + "'";
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
            throw new Error('Buffers not yet supported');
            if (param.type.toUpperCase() !== 'BINARY' && param.type.toUpperCase() !== 'VARBINARY') {
              throw new Error('Must use BINARY or VARBINARY for buffer parameters');
            }
            sql = 'DECLARE @__temp__' + key + ' ' + param.type + '(' + value.length + '); SET @__temp__' + key + ' = CONVERT(' + param.type + '(' + value.length + "), N'" + value.toString('ucs2').replace(/'/g, "''") + "'); " + sql;
            paramSql += '@__temp__' + key;
          } else {
            throw new Error('Unsupported parameter type: ' + typeof value);
          }
          break;
        default:
          throw new Error('Unsupported parameter type: ' + typeof value);
      }
    }
    if (paramSql === '') {
      return sql;
    } else {
      return sql + ', ' + paramSql;
    }
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
    throw new Error('Unimplemented');
  };

  return TdsUtils;

})();
