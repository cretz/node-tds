var Connection, EventEmitter, PreparedStatement, Statement, TdsClient;
var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

EventEmitter = require('./events').EventEmitter;

TdsClient = require('./tds-client').TdsClient;

Connection = (function() {

  __extends(Connection, EventEmitter);

  function Connection(_options) {
    this._options = _options;
    this._client = new TdsClient;
  }

  Connection.prototype.connect = function(cb) {};

  Connection.prototype.createStatement = function(sql, params) {};

  Connection.prototype.prepareStatement = function(sql, params) {};

  return Connection;

})();

Statement = (function() {

  __extends(Statement, EventEmitter);

  function Statement(_connection, _sql, _params) {
    this._connection = _connection;
    this._sql = _sql;
    this._params = _params;
  }

  Statement.prototype.execute = function(paramValues) {
    return this._connection.currentStatement = this;
  };

  return Statement;

})();

PreparedStatement = (function() {

  __extends(PreparedStatement, Statement);

  function PreparedStatement(_connection, _handle, _sql, _params) {
    this._connection = _connection;
    this._handle = _handle;
    this._sql = _sql;
    this._params = _params;
  }

  PreparedStatement.prototype._prepare = function() {};

  PreparedStatement.prototype.execute = function(paramValues) {
    return this._connection.currentStatement = this;
  };

  return PreparedStatement;

})();
