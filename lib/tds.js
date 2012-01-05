var EventEmitter, Statement, TdsClient, TdsError, TdsUtils,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

EventEmitter = require('events').EventEmitter;

TdsClient = require('./tds-client').TdsClient;

TdsUtils = require('./tds-utils').TdsUtils;

/**
Connection class for connecting to SQL Server
*/

exports.Connection = (function(_super) {

  __extends(Connection, _super);

  function Connection(_options) {
    var _ref, _ref2,
      _this = this;
    this._options = _options;
    this.end = __bind(this.end, this);
    this.rollback = __bind(this.rollback, this);
    this.commit = __bind(this.commit, this);
    this.setAutoCommit = __bind(this.setAutoCommit, this);
    this.prepareBulkLoad = __bind(this.prepareBulkLoad, this);
    this.createCall = __bind(this.createCall, this);
    this.createStatement = __bind(this.createStatement, this);
    this.connect = __bind(this.connect, this);
    this._autoCommit = true;
    this._client = new TdsClient({
      error: function(err) {
        var cb, _base;
        if (_this._pendingCallback != null) {
          _this._currentStatement = null;
          cb = _this._pendingCallback;
          _this._pendingCallback = null;
          return cb(err);
        } else if (_this._pendingLoginCallback != null) {
          cb = _this._pendingLoginCallback;
          _this._pendingLoginCallback = null;
          return cb(err);
        } else if (_this._currentStatement != null) {
          return _this._currentStatement._error(err);
        } else if (_this.handler != null) {
          return typeof (_base = _this.handler).error === "function" ? _base.error(err) : void 0;
        } else {
          return _this.emit('error', err);
        }
      },
      message: function(message) {
        var cb, err, _base, _base2;
        if (message.error) {
          err = new TdsError(message.text, message);
          if (_this._pendingCallback != null) {
            _this._currentStatement = null;
            cb = _this._pendingCallback;
            _this._pendingCallback = null;
            return cb(err);
          } else if (_this._pendingLoginCallback != null) {
            cb = _this._pendingLoginCallback;
            _this._pendingLoginCallback = null;
            return cb(err);
          } else if (_this._currentStatement != null) {
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
        var _ref;
        return (_ref = _this._currentStatement) != null ? _ref._row(row) : void 0;
      },
      colmetadata: function(colmetadata) {
        var _ref;
        return (_ref = _this._currentStatement) != null ? _ref._colmetadata(colmetadata) : void 0;
      },
      done: function(done) {
        var cb;
        if (done.hasMore) return;
        if (_this._pendingCallback != null) {
          if (_this._currentStatement === '#setAutoCommit') {
            _this._autoCommit = !_this._autoCommit;
          }
          _this._currentStatement = null;
          cb = _this._pendingCallback;
          _this._pendingCallback = null;
          return cb();
        } else if (_this._currentStatement != null) {
          return _this._currentStatement._done(done);
        }
      }
    });
    this._client.logError = (_ref = this._options) != null ? _ref.logError : void 0;
    this._client.logDebug = (_ref2 = this._options) != null ? _ref2.logDebug : void 0;
  }

  Connection.prototype.connect = function(_pendingLoginCallback) {
    this._pendingLoginCallback = _pendingLoginCallback;
    return this._client.connect(this._options);
  };

  Connection.prototype.createStatement = function(sql, params, handler) {
    if (this._currentStatement) throw new Error('Statement currently running');
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

  Connection.prototype.setAutoCommit = function(autoCommit, autoCommitCallback) {
    if (this._autoCommit === autoCommit) {
      return cb();
    } else {
      if (this._currentStatement != null) {
        throw new Error('Cannot change auto commit while statement is executing');
      }
      this._pendingCallback = autoCommitCallback;
      this._currentStatement = '#setAutoCommit';
      if (autoCommit) {
        return this._client.sqlBatch('SET IMPLICIT_TRANSACTIONS OFF');
      } else {
        return this._client.sqlBatch('SET IMPLICIT_TRANSACTIONS ON');
      }
    }
  };

  Connection.prototype.commit = function(commitCallback) {
    if (this._autoCommit) throw new Error('Auto commit is on');
    if (this._currentStatement != null) {
      throw new Error('Cannot commit while statement is executing');
    }
    this._pendingCallback = commitCallback;
    this._currentStatement = '#commit';
    return this._client.sqlBatch('IF @@TRANCOUNT > 0 COMMIT TRANSACTION');
  };

  Connection.prototype.rollback = function(rollbackCallback) {
    if (this._autoCommit) throw new Error('Auto commit is on');
    if (this._currentStatement != null) {
      throw new Error('Cannot rollback while statement is executing');
    }
    this._pendingCallback = rollbackCallback;
    this._currentStatement = '#rollback';
    return this._client.sqlBatch('IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION');
  };

  Connection.prototype.end = function() {
    this._autoCommit = true;
    this._pendingCallback = null;
    this._currentStatement = null;
    return this._client.end();
  };

  return Connection;

})(EventEmitter);

/**
Statement class
*/

Statement = exports.Statement = (function(_super) {

  __extends(Statement, _super);

  function Statement(_connection, _sql, _params, handler) {
    this._connection = _connection;
    this._sql = _sql;
    this._params = _params;
    this.handler = handler;
    this._done = __bind(this._done, this);
    this._row = __bind(this._row, this);
    this._colmetadata = __bind(this._colmetadata, this);
    this._message = __bind(this._message, this);
    this._error = __bind(this._error, this);
    this.cancel = __bind(this.cancel, this);
    this.execute = __bind(this.execute, this);
    if (this._params != null) {
      this._parameterString = TdsUtils.buildParameterDefinition(this._params);
    }
  }

  Statement.prototype.prepare = function(cb) {
    var sql;
    if (this._preparedHandle != null) {
      throw new Error('Statement already prepared');
    }
    if (!(this._parameterString != null) || this._parameterString === '') {
      throw new Error('Cannot prepare statement without parameters');
    }
    if (this._connection._currentStatement != null) {
      throw new Error('Another statement already executing');
    }
    this._connection._currentStatement = this;
    sql = "DECLARE @hndl Int;\nEXECUTE sp_prepare @hndl OUTPUT, N'" + this._parameterString + "',\nN'" + this._sql.replace(/'/g, "''") + "\n', 1;\nSELECT @hndl;";
    this._pendingPrepareCallback = cb;
    return this._connection._client.sqlBatch(sql);
  };

  Statement.prototype.unprepare = function(cb) {
    if (!(this._preparedHandle != null)) throw new Error('Statement not prepared');
    if (this._connection._currentStatement != null) {
      throw new Error('Another statement already executing');
    }
    this._connection._currentStatement = this;
    this._pendingUnprepareCallback = cb;
    return this._connection._client.sqlBatch('sp_unprepare ' + this._preparedHandle);
  };

  Statement.prototype.execute = function(paramValues) {
    var sql;
    if (this._connection._currentStatement != null) {
      throw new Error('Another statement already executing');
    }
    this._connection._currentStatement = this;
    sql = null;
    if (!(this._params != null) || this._parameterString === '') {
      sql = this._sql;
    } else if (this._preparedHandle != null) {
      sql = 'EXECUTE sp_execute ' + this._preparedHandle + ', ' + TdsUtils.buildParameterizedSql(this._params, paramValues);
    } else {
      if (!(this._parameterizedSql != null)) {
        this._parameterizedSql = "EXECUTE sp_executesql \nN'" + this._sql.replace(/'/g, "''") + "\n', N'" + this._parameterString + "'";
      }
      sql = this._parameterizedSql + ', ' + TdsUtils.buildParameterizedSql(this._params, paramValues);
    }
    return this._connection._client.sqlBatch(sql);
  };

  Statement.prototype.cancel = function() {
    if ((this._pendingPrepareCallback != null) || (this._pendingUnprepareCallback != null)) {
      throw new Error('Unable to cancel (un)prepare');
    }
    this._cancelling = true;
    return this._connection._client.cancel();
  };

  Statement.prototype._error = function(err) {
    var cb, _base;
    if (this._pendingPrepareCallback != null) {
      cb = this._pendingPrepareCallback;
      this._pendingPrepareCallback = null;
      this._connection.currentStatement = null;
      cb(err);
      return this._ignoreNextDone = true;
    } else if (this._pendingUnprepareCallback != null) {
      cb = this._pendingUnprepareCallback;
      this._pendingUnprepareCallback = null;
      this._connection.currentStatement = null;
      cb(err);
      return this._ignoreNextDone = true;
    } else if (this.handler != null) {
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
    if (!this._cancelling && !(this._pendingPrepareCallback != null) && !(this._pendingUnprepareCallback != null)) {
      this.metadata = colmetadata;
      if (this.handler != null) {
        return typeof (_base = this.handler).metadata === "function" ? _base.metadata(this.metadata) : void 0;
      } else {
        return this.emit('metadata', this.metadata);
      }
    }
  };

  Statement.prototype._row = function(row) {
    var _base;
    if (this._pendingPrepareCallback != null) {
      return this._preparedHandle = row.getValue(0);
    } else if (!this._cancelling) {
      if (this.handler != null) {
        return typeof (_base = this.handler).row === "function" ? _base.row(row) : void 0;
      } else {
        return this.emit('row', row);
      }
    }
  };

  Statement.prototype._done = function(done) {
    var cb, _base;
    if (this._ignoreNextDone) {
      return this._ignoreNextDone = void 0;
    } else if (this._pendingPrepareCallback != null) {
      cb = this._pendingPrepareCallback;
      this._pendingPrepareCallback = null;
      this._connection._currentStatement = null;
      return cb();
    } else if (this._pendingUnprepareCallback != null) {
      cb = this._pendingUnprepareCallback;
      this._pendingUnprepareCallback = null;
      this._preparedHandle = void 0;
      this._connection._currentStatement = null;
      return cb();
    } else {
      if (this._cancelling) this._cancelling = void 0;
      this._connection._currentStatement = null;
      if (this.handler != null) {
        return typeof (_base = this.handler).done === "function" ? _base.done(done) : void 0;
      } else {
        return this.emit('done', done);
      }
    }
  };

  return Statement;

})(EventEmitter);

/**
TdsError class
*/

TdsError = exports.TdsError = (function(_super) {

  __extends(TdsError, _super);

  function TdsError(message, info) {
    this.message = message;
    this.info = info;
    this.name = 'TdsError';
    this.stack = (new Error).stack;
  }

  return TdsError;

})(Error);
