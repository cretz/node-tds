var Connection, EventEmitter, Statement, TdsClient;
var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

EventEmitter = require('./events').EventEmitter;

TdsClient = require('./tds-client').TdsClient;

Connection = (function() {

  __extends(Connection, EventEmitter);

  function Connection(_options) {
    this._options = _options;
    this._client = new TdsClient({
      error: function(error) {
        var _base, _base2;
        if (this._currentStatement != null) {
          return typeof (_base = this._currentStatement.handler).error === "function" ? _base.error(error) : void 0;
        } else {
          return typeof (_base2 = this.handler).error === "function" ? _base2.error(error) : void 0;
        }
      },
      message: function(message) {
        var _base, _base2;
        if (this._currentStatement != null) {
          return typeof (_base = this._currentStatement.handler).message === "function" ? _base.message(message) : void 0;
        } else {
          return typeof (_base2 = this.handler).message === "function" ? _base2.message(message) : void 0;
        }
      },
      connect: function(connect) {
        return this._client.login(this._options);
      },
      login: function(login) {
        var cb;
        cb = this._pendingLoginCallback;
        this._pendingLoginCallback = null;
        return typeof cb === "function" ? cb() : void 0;
      },
      row: function(row) {
        return this._currentStatement.row(row);
      },
      colmetadata: function(colmetadata) {
        return this._currentStatement.colmetadata(colmetadata);
      }
    });
  }

  Connection.prototype.connect = function(cb) {};

  Connection.prototype.createStatement = function(sql, params, handler) {
    return new Statement(this, sql, params, cb);
  };

  Connection.prototype.createCall = function(procName, params, handler) {};

  Connection.prototype.prepareBulkLoad = function(tableName, batchSize, columns, cb) {};

  Connection.prototype.setAutoCommit = function(autoCommit, cb) {
    this.autoCommit = autoCommit;
  };

  Connection.prototype.commit = function(cb) {};

  Connection.prototype.rollback = function(cb) {};

  Connection.prototype.end = function() {
    return this._client.end();
  };

  return Connection;

})();

Statement = (function() {

  __extends(Statement, EventEmitter);

  function Statement(_connection, sql, _params, handler) {
    var key, parameterString, value, _ref;
    this._connection = _connection;
    this._params = _params;
    this.handler = handler;
    this._sql = sql.replace("'", "''");
    if (this._params != null) {
      parameterString = '';
      _ref = this._params;
      for (key in _ref) {
        value = _ref[key];
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
        if (parameterString !== '') parameterString += ',';
        parameterString += '@' + key + ' ' + value.type;
        if (value.size != null) {
          parameterString += '(' + value.size + ')';
        } else if ((value.scale != null) && (value.precision != null)) {
          parameterString += '(' + value.precision + ',' + value.scale + ')';
        }
        if (value.output) parameterString += ' OUTPUT';
      }
      this._sql = "EXECUTE sp_executesql N'" + this._sql + "', N'" + parameterString + "'";
    }
  }

  Statement.prototype.execute = function(paramValues) {
    var key, param, paramSql, value;
    this._connection._currentStatement = this;
    if (!(this._params != null)) {
      return this._connection._client.sqlBatch(this._sql);
    } else {
      paramSql = '';
      for (key in paramValues) {
        value = paramValues[key];
        param = this._params[key];
        if (!(param != null)) throw new Error('Undefined parameter ' + key);
        if (paramSql !== '') paramSql += ', ';
        paramSql += '@' + key + ' = ';
        switch (typeof value) {
          case 'string':
            paramSql += "N'" + value.replace("'", "''");
            break;
          case 'number':
            paramSql += value;
            break;
          case 'boolean':
            paramSql += value ? 1 : 0;
            break;
          case 'null':
            paramSql += 'NULL';
            break;
          case 'object':
            if (value instanceof Date) {
              paramSql += "'" + this._formatDate(value, !param.timeOnly, !param.dateOnly) + "'";
            } else {
              throw new Error('Unsupported parameter type: ' + typeof value);
            }
            break;
          default:
            throw new Error('Unsupported parameter type: ' + typeof value);
        }
      }
      if (paramSql !== '') {
        return this._connection._client.sqlBatch(this._sql + ', ' + paramSql);
      } else {
        return this._connection._client.sqlBatch(this._sql);
      }
    }
  };

  Statement.prototype.cancel = function() {};

  Statement.prototype._formatDate = function(date, includeDate, includeTime) {
    var str;
    str = '';
    if (includeDate) {
      if (date.getFullYear() < 1000) str += '0';
      if (date.getFullYear() < 100) str += '0';
      if (date.getFullYear() < 10) str += '0';
      str += date.getFullYear() + '-';
      if (date.getMonth() < 10) str += '0';
      str += date.getMonth() + '-';
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

  return Statement;

})();
