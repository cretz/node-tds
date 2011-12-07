var BufferBuilder, BufferStream, ColMetaDataPacket, DonePacket, ErrorMessagePacket, InfoMessagePacket, Login7Packet, LoginAckPacket, Packet, PreLoginPacket, RowPacket, Socket, SqlBatchPacket, StreamIndexOutOfBoundsError, TdsConstants, _ref;
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

Socket = require('net').Socket;

BufferBuilder = require('./buffer-builder').BufferBuilder;

_ref = require('./buffer-stream'), BufferStream = _ref.BufferStream, StreamIndexOutOfBoundsError = _ref.StreamIndexOutOfBoundsError;

ColMetaDataPacket = require('./colmetadata.packet').ColMetaDataPacket;

DonePacket = require('./done.packet').DonePacket;

ErrorMessagePacket = require('./error.message.packet').ErrorMessagePacket;

InfoMessagePacket = require('./info.message.packet').InfoMessagePacket;

Login7Packet = require('./login7.packet').Login7Packet;

LoginAckPacket = require('./loginack.packet').LoginAckPacket;

Packet = require('./packet').Packet;

PreLoginPacket = require('./prelogin.packet').PreLoginPacket;

RowPacket = require('./row.packet').RowPacket;

SqlBatchPacket = require('./sqlbatch.packet').SqlBatchPacket;

TdsConstants = require('./tds-constants').TdsConstants;

exports.TdsClient = (function() {

  TdsClient.prototype._socket = null;

  TdsClient.prototype._preLoginConfig = null;

  TdsClient.prototype._stream = null;

  TdsClient.prototype._handler = null;

  TdsClient.prototype.logDebug = false;

  TdsClient.prototype.logError = false;

  TdsClient.prototype.state = TdsConstants.statesByName['INITIAL'];

  function TdsClient(_handler) {
    this._handler = _handler;
    this._socketClose = __bind(this._socketClose, this);
    this._socketEnd = __bind(this._socketEnd, this);
    this._socketData = __bind(this._socketData, this);
    this._socketError = __bind(this._socketError, this);
    this._socketConnect = __bind(this._socketConnect, this);
    if (!(this._handler != null)) throw new Error('Handler required');
  }

  TdsClient.prototype.connect = function(config) {
    var _ref2, _ref3, _ref4;
    if (this.state !== TdsConstants.statesByName['INITIAL']) {
      throw new Error('Client must be in INITIAL state before connecting');
    }
    this.state = TdsConstants.statesByName['CONNECTING'];
    if (this.logDebug) {
      console.log('Connecting to SQL Server with config %j', config);
    }
    try {
      this._preLoginConfig = config;
      this._socket = new Socket();
      this._socket.on('connect', this._socketConnect);
      this._socket.on('error', this._socketError);
      this._socket.on('data', this._socketData);
      this._socket.on('end', this._socketEnd);
      this._socket.on('close', this._socketClose);
      return this._socket.connect((_ref2 = config.port) != null ? _ref2 : 1433, (_ref3 = config.host) != null ? _ref3 : 'localhost');
    } catch (err) {
      if (this.logError) console.error('Error connecting: ' + err);
      this.state = TdsConstants.statesByName['INITIAL'];
      if ((_ref4 = this._handler) != null) {
        if (typeof _ref4.error === "function") _ref4.error(err);
      }
      return this.end();
    }
  };

  TdsClient.prototype.login = function(config) {
    var key, login, value, _base;
    if (this.state !== TdsConstants.statesByName['CONNECTED']) {
      throw new Error('Client must be in CONNECTED state before logging in');
    }
    this.state = TdsConstants.statesByName['LOGGING IN'];
    if (this.logDebug) console.log('Logging in with config %j', config);
    try {
      login = new Login7Packet;
      for (key in config) {
        value = config[key];
        if (login.hasOwnProperty(key)) login[key] = value;
      }
      return this._sendPacket(login);
    } catch (err) {
      if (this.logError) console.error('Error on login: ', err);
      this.state = TdsConstants.statesByName['CONNECTED'];
      return typeof (_base = this._handler).error === "function" ? _base.error(err) : void 0;
    }
  };

  TdsClient.prototype.sqlBatch = function(sqlText) {
    var sqlBatch, _base;
    if (this.state !== TdsConstants.statesByName['LOGGED IN']) {
      throw new Error('Client must be in LOGGED IN state before executing sql');
    }
    if (this.logDebug) console.log('Executing SQL Batch: %s', sqlText);
    try {
      sqlBatch = new SqlBatchPacket;
      sqlBatch.sqlText = sqlText;
      return this._sendPacket(sqlBatch);
    } catch (err) {
      if (this.logError) console.error('Error executing: ', err);
      return typeof (_base = this._handler).error === "function" ? _base.error(err) : void 0;
    }
  };

  TdsClient.prototype._socketConnect = function() {
    var key, prelogin, value, _ref2, _ref3;
    if (this.logDebug) console.log('Connection established, pre-login commencing');
    try {
      this._stream = new BufferStream;
      prelogin = new PreLoginPacket;
      _ref2 = this._preLoginConfig;
      for (key in _ref2) {
        value = _ref2[key];
        if (prelogin.hasOwnProperty(key)) prelogin[key] = value;
      }
      return this._sendPacket(prelogin);
    } catch (err) {
      if (this.logError) console.error('Error on pre-login: ', err);
      this.state = TdsConstants.statesByName['INITIAL'];
      if ((_ref3 = this._handler) != null) {
        if (typeof _ref3.error === "function") _ref3.error(err);
      }
      return this.end();
    }
  };

  TdsClient.prototype._socketError = function(error) {
    var _base;
    if (this.logError) console.error('Error in socket: ', error);
    if (typeof (_base = this._handler).error === "function") _base.error(err);
    return this.end();
  };

  TdsClient.prototype._getPacketFromType = function(type) {
    switch (type) {
      case ColMetaDataPacket.type:
        return ColMetaDataPacket;
      case DonePacket.type:
        return DonePacket;
      case ErrorMessagePacket.type:
        return ErrorMessagePacket;
      case InfoMessagePacket.type:
        return InfoMessagePacket;
      case Login7Packet.type:
        return Login7Packet;
      case LoginAckPacket.type:
        return LoginAckPacket;
      case PreLoginPacket.type:
        return PreLoginPacket;
      case RowPacket.type:
        return RowPacket;
      case SqlBatchPacket.type:
        return SqlBatchPacket;
      default:
        throw new Error('Unrecognized type: ' + header.type);
    }
  };

  TdsClient.prototype._socketData = function(data) {
    var header, packet, _base, _base2, _base3, _base4, _base5, _base6, _base7;
    if (this.logDebug) console.log('Received %d bytes', data.length);
    header = null;
    packet = null;
    try {
      this._stream.append(data);
      this._stream.beginTransaction();
      header = Packet.retrieveHeader(this._stream, this);
      packet = new this._getPacketFromType(header.type);
      packet.fromBuffer(this._stream, this);
      this._stream.commitTransaction();
    } catch (err) {
      if (err instanceof StreamIndexOutOfBoundsError) {
        if (this.logDebug) console.log('Stream incomplete, rolling back');
        this._stream.rollbackTransaction();
      } else {
        if (this.logError) console.error('Error reading stream: ', err);
        throw err;
      }
      return;
    }
    if (this.logDebug) console.log('Handling packet of type %s', packet.name);
    try {
      switch (packet.type) {
        case ColMetaDataPacket.type:
          this.columns = packet.columns;
          return typeof (_base = this._handler).metadata === "function" ? _base.metadata(packet) : void 0;
        case DonePacket.type:
          return typeof (_base2 = this._handler).done === "function" ? _base2.done(packet) : void 0;
        case ErrorMessagePacket.type:
          switch (this.state) {
            case TdsConstants.statesByName['CONNECTING']:
              this.state = TdsConstants.statesByName['INITIAL'];
              this.end();
              break;
            case TdsConstants.statesByName['LOGGING IN']:
              this.state = TdsConstants.statesByName['CONNECTED'];
          }
          return typeof (_base3 = this._handler).error === "function" ? _base3.error(packet) : void 0;
        case InfoMessagePacket.type:
          return typeof (_base4 = this._handler).info === "function" ? _base4.info(packet) : void 0;
        case LoginAckPacket.type:
          this.state = TdsConstants.statesByName['LOGGED IN'];
          return typeof (_base5 = this._handler).login === "function" ? _base5.login(packet) : void 0;
        case PreLoginPacket.type:
          this.state = TdsConstants.statesByName['CONNECTED'];
          return typeof (_base6 = this._handler).connect === "function" ? _base6.connect(packet) : void 0;
        case RowPacket.type:
          return typeof (_base7 = this._handler).row === "function" ? _base7.row(packet) : void 0;
        default:
          if (this.logError) console.error('Unrecognized type: ' + packet.type);
          throw new Error('Unrecognized type: ' + packet.type);
      }
    } catch (err) {
      if (this.logError) console.error('Error reading stream: ', err);
      throw err;
    }
  };

  TdsClient.prototype._socketEnd = function() {
    var _ref2;
    if (this.logDebug) console.log('Socket ended remotely');
    this._socket = null;
    this.state = TdsConstants.statesByName['INITIAL'];
    return (_ref2 = this._handler) != null ? typeof _ref2.end === "function" ? _ref2.end() : void 0 : void 0;
  };

  TdsClient.prototype._socketClose = function() {
    if (this.logDebug) console.log('Socket closed');
    this._socket = null;
    return this.state = TdsConstants.statesByName['INITIAL'];
  };

  TdsClient.prototype._sendPacket = function(packet) {
    var buff, builder;
    if (this.logDebug) console.log('Sending packet: %s', packet.name);
    builder = packet.toBuffer(new BufferBuilder, this);
    buff = builder.toBuffer();
    if (this.logDebug) console.log('Packet size: %d', buff.length);
    return this._socket.write(buff);
  };

  TdsClient.prototype.end = function() {
    if (this.logDebug) console.log('Ending socket');
    try {
      this._socket.end();
    } catch (_error) {}
    this._socket = null;
    return this.state = TdsConstants.statesByName['INITIAL'];
  };

  return TdsClient;

})();
