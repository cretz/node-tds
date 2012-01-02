var EventEmitter, Statement, TdsClient, TdsError, TdsUtils;
var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

EventEmitter = require('events').EventEmitter;

TdsClient = require('./tds-client').TdsClient;

TdsUtils = require('./tds-utils').TdsUtils;

exports.Connection = (function() {

  __extends(Connection, EventEmitter);

  function Connection(_options) {
    var _ref, _ref2;
    var _this = this;
    this._options = _options;
    this._client = new TdsClient({
      message: function(message) {
        var err, _base, _base2;
        if (message.error) {
          err = new TdsError(message.text, message);
          if (_this._currentStatement != null) {
            return _this._currentStatement._error(err);
          } else if (_this.handler != null) {
            return typeof (_base = _this.handler).error === "function" ? _base.error(err) : void 0;
          } else {
            return _this.emit('error', err);
          }
        } else if (_this._currentStatement != null) {
          return _this._currentStatement._message(message);
        } else if (_this.handler != null) {
          return typeof (_base2 = _this.handler).message === "function" ? _base2.message(message) : void 0;
        } else {
          return _this.emit('message', message);
        }
      },
      connect: function(connect) {
        return _this._client.login(_this._options);
      },
      login: function(login) {
        var cb;
        cb = _this._pendingLoginCallback;
        _this._pendingLoginCallback = null;
        return typeof cb === "function" ? cb() : void 0;
      },
      row: function(row) {
        return _this._currentStatement._row(row);
      },
      colmetadata: function(colmetadata) {
        return _this._currentStatement._colmetadata(colmetadata);
      },
      done: function(done) {
        var _ref;
        return (_ref = _this._currentStatement) != null ? _ref._done(done) : void 0;
      }
    });
    this._client.logError = (_ref = this._options) != null ? _ref.logError : void 0;
    this._client.logDebug = (_ref2 = this._options) != null ? _ref2.logDebug : void 0;
    this.__defineGetter__('isExecutingStatement', function() {
      return this._currentStatement != null;
    });
  }

  Connection.prototype.connect = function(_pendingLoginCallback) {
    this._pendingLoginCallback = _pendingLoginCallback;
    return this._client.connect(this._options);
  };

  Connection.prototype.createStatement = function(sql, params, handler) {
    if (this.isExecutingStatement) throw new Error('Statement currently running');
    if (this._options.logDebug) {
      console.log('Creating statement: %s with params: ', sql, params);
    }
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
    this._currentStatement = null;
    return this._client.end();
  };

  return Connection;

})();

Statement = exports.Statement = (function() {

  __extends(Statement, EventEmitter);

  function Statement(_connection, _sql, _params, handler) {
    var parameterString;
    this._connection = _connection;
    this._sql = _sql;
    this._params = _params;
    this.handler = handler;
    if (this._params != null) {
      parameterString = TdsUtils.buildParameterDefinition(this._params);
      if (parameterString !== '') {
        this._sql = "EXECUTE sp_executesql N'" + this._sql.replace("'", "''") + "', N'" + parameterString + "'";
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

  Statement.prototype._error = function(err) {
    var _base;
    if (this.handler != null) {
      return typeof (_base = this.handler).error === "function" ? _base.error(err) : void 0;
    } else {
      return this.emit('error', err);
    }
  };

  Statement.prototype._message = function(message) {
    var _base;
    if (this.handler != null) {
      return typeof (_base = this.handler).message === "function" ? _base.message(message) : void 0;
    } else {
      return this.emit('message', message);
    }
  };

  Statement.prototype._colmetadata = function(colmetadata) {
    var _base;
    this.metadata = colmetadata;
    if (this.handler != null) {
      return typeof (_base = this.handler).metadata === "function" ? _base.metadata(this.metadata) : void 0;
    } else {
      return this.emit('metadata', this.metadata);
    }
  };

  Statement.prototype._row = function(row) {
    var _base;
    if (this.handler != null) {
      return typeof (_base = this.handler).row === "function" ? _base.row(row) : void 0;
    } else {
      return this.emit('row', row);
    }
  };

  Statement.prototype._done = function(done) {
    var _base;
    if (!done.hasMore) this._connection._currentStatement = null;
    if (this.handler != null) {
      return typeof (_base = this.handler).done === "function" ? _base.done(done) : void 0;
    } else {
      return this.emit('done', done);
    }
  };

  return Statement;

})();

TdsError = exports.TdsError = (function() {

  __extends(TdsError, Error);

  function TdsError(message, info) {
    this.message = message;
    this.info = info;
    this.name = 'TdsError';
    this.stack = (new Error).stack;
  }

  return TdsError;

})();
