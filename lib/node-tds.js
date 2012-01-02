var EventEmitter, Statement, TdsClient, TdsUtils;
var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

EventEmitter = require('./events').EventEmitter;

TdsClient = require('./tds-client').TdsClient;

TdsUtils = require('./tds-utils').TdsUtils;

exports.Connection = (function() {

  __extends(Connection, EventEmitter);

  function Connection(_options) {
    this._options = _options;
    this._client = new TdsClient({
      message: function(message) {
        var err, _base, _base2;
        if (message.error) {
          err = new TdsError(message.text, message);
          if (this._currentStatement != null) {
            return this._currentStatement.error(err);
          } else if (this.handler != null) {
            return typeof (_base = this.handler).error === "function" ? _base.error(err) : void 0;
          } else {
            return this.emit('error', err);
          }
        } else if (this._currentStatement != null) {
          return this._currentStatement.message(message);
        } else if (this.handler != null) {
          return typeof (_base2 = this.handler).message === "function" ? _base2.message(message) : void 0;
        } else {
          return this.emit('message', message);
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
      },
      done: function(done) {
        return this._currentStatement.done(done);
      }
    });
  }

  Connection.prototype.connect = function(cb) {
    throw new Error('Not yet implemented');
  };

  Connection.prototype.createStatement = function(sql, params, handler) {
    return new Statement(this, sql, params, handler);
  };

  Connection.prototype.createCall = function(procName, params, handler) {
    throw new Error('Not yet implemented');
  };

  Connection.prototype.prepareBulkLoad = function(tableName, batchSize, columns, cb) {
    throw new Error('Not yet implemented');
  };

  Connection.prototype.setAutoCommit = function(autoCommit, cb) {
    this.autoCommit = autoCommit;
    throw new Error('Not yet implemented');
  };

  Connection.prototype.commit = function(cb) {
    throw new Error('Not yet implemented');
  };

  Connection.prototype.rollback = function(cb) {
    throw new Error('Not yet implemented');
  };

  Connection.prototype.end = function() {
    return this._client.end();
  };

  return Connection;

})();

Statement = (function() {

  __extends(Statement, EventEmitter);

  function Statement(_connection, sql, _params, handler) {
    var parameterString;
    this._connection = _connection;
    this._params = _params;
    this.handler = handler;
    this._sql = sql.replace("'", "''");
    if (this._params != null) {
      parameterString = TdsUtils.buildParameterDefinition(this._params);
      if (parameterString !== '') {
        this._sql = "EXECUTE sp_executesql N'" + this._sql + "', N'" + parameterString + "'";
      }
    }
  }

  Statement.prototype.execute = function(paramValues) {
    var paramSql;
    this._connection._currentStatement = this;
    if (!(this._params != null)) {
      return this._connection._client.sqlBatch(this._sql);
    } else {
      paramSql = TdsUtils.buildParameterSql(this._params, paramValues);
      if (paramSql !== '') {
        return this._connection._client.sqlBatch(this._sql + ', ' + paramSql);
      } else {
        return this._connection._client.sqlBatch(this._sql);
      }
    }
  };

  Statement.prototype.cancel = function() {
    throw new Error('Not yet implemented');
  };

  Statement.prototype.error = function(err) {
    var _base;
    if (this.handler != null) {
      return typeof (_base = this.handler).error === "function" ? _base.error(err) : void 0;
    } else {
      return this.emit('error', err);
    }
  };

  Statement.prototype.message = function(message) {
    var _base;
    if (this.handler != null) {
      return typeof (_base = this.handler).message === "function" ? _base.message(message) : void 0;
    } else {
      return this.emit('message', message);
    }
  };

  Statement.prototype.colmetadata = function(colmetadata) {
    var _base;
    this.columns = colmetadata.columns;
    if (this.handler != null) {
      return typeof (_base = this.handler).metadata === "function" ? _base.metadata(this.columns) : void 0;
    } else {
      return this.emit('metadata', this.columns);
    }
  };

  Statement.prototype.row = function(row) {
    var _base;
    if (this.handler != null) {
      return typeof (_base = this.handler).row === "function" ? _base.row(row) : void 0;
    } else {
      return this.emit('row', row);
    }
  };

  Statement.prototype.done = function(done) {
    var _base;
    if (this.handler != null) {
      return typeof (_base = this.handler).done === "function" ? _base.done(done) : void 0;
    } else {
      return this.emit('done', done);
    }
  };

  return Statement;

})();

exports.TdsError = (function() {

  __extends(TdsError, Error);

  function TdsError(message, info) {
    this.message = message;
    this.info = info;
    this.stack = (new Error).stack;
  }

  return TdsError;

})();
