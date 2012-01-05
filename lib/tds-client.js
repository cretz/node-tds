var AttentionPacket, BufferBuilder, BufferStream, ColMetaDataToken, DoneToken, Login7Packet, LoginAckToken, Packet, PreLoginPacket, Socket, SqlBatchPacket, StreamIndexOutOfBoundsError, TdsConstants, TokenStreamPacket, _ref,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

Socket = require('net').Socket;

AttentionPacket = require('./attention.packet').AttentionPacket;

BufferBuilder = require('./buffer-builder').BufferBuilder;

_ref = require('./buffer-stream'), BufferStream = _ref.BufferStream, StreamIndexOutOfBoundsError = _ref.StreamIndexOutOfBoundsError;

ColMetaDataToken = require('./colmetadata.token').ColMetaDataToken;

DoneToken = require('./done.token').DoneToken;

Login7Packet = require('./login7.packet').Login7Packet;

LoginAckToken = require('./loginack.token').LoginAckToken;

Packet = require('./packet').Packet;

PreLoginPacket = require('./prelogin.packet').PreLoginPacket;

SqlBatchPacket = require('./sqlbatch.packet').SqlBatchPacket;

TdsConstants = require('./tds-constants').TdsConstants;

TokenStreamPacket = require('./tokenstream.packet').TokenStreamPacket;

/**
Low level client for TDS access
*/

exports.TdsClient = (function() {

  function TdsClient(_handler) {
    this._handler = _handler;
    this._socketClose = __bind(this._socketClose, this);
    this._socketEnd = __bind(this._socketEnd, this);
    this._socketData = __bind(this._socketData, this);
    this._socketError = __bind(this._socketError, this);
    this._socketConnect = __bind(this._socketConnect, this);
    if (!(this._handler != null)) throw new Error('Handler required');
    this.logDebug = this.logError = false;
    this.state = TdsConstants.statesByName['INITIAL'];
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
    var key, login, value, _base, _ref2;
    if (this.state !== TdsConstants.statesByName['CONNECTED']) {
      throw new Error('Client must be in CONNECTED state before logging in');
    }
    this.state = TdsConstants.statesByName['LOGGING IN'];
    if (this.logDebug) console.log('Logging in with config %j', config);
    try {
      login = new Login7Packet;
      for (key in config) {
        value = config[key];
        login[key] = value;
      }
      this.tdsVersion = (_ref2 = config.tdsVersion) != null ? _ref2 : TdsConstants.versionsByVersion['7.1.1'];
      return this._sendPacket(login);
    } catch (err) {
      if (this.logError) console.error('Error on login: ', err);
      this.state = TdsConstants.statesByName['CONNECTED'];
      return typeof (_base = this._handler).error === "function" ? _base.error(err) : void 0;
    }
  };

  TdsClient.prototype.sqlBatch = function(sqlText) {
    var sqlBatch, _ref2;
    if (this.state !== TdsConstants.statesByName['LOGGED IN']) {
      throw new Error('Client must be in LOGGED IN state before executing sql');
    }
    if (this.logDebug) console.log('Executing SQL Batch: %s', sqlText);
    try {
      sqlBatch = new SqlBatchPacket;
      sqlBatch.sqlText = sqlText;
      return this._sendPacket(sqlBatch);
    } catch (err) {
      if (this.logError) console.error('Error executing: ', err.stack);
      return (_ref2 = this._handler) != null ? typeof _ref2.error === "function" ? _ref2.error(err) : void 0 : void 0;
    }
  };

  TdsClient.prototype.cancel = function() {
    var _ref2;
    if (this.state !== TdsConstants.statesByName['LOGGED IN']) {
      throw new Error('Client must be in LOGGED IN state before cancelling');
    }
    if (this.logDebug) console.log('Cancelling');
    try {
      this.cancelling = true;
      return this._sendPacket(new AttentionPacket);
    } catch (err) {
      this.cancelling = void 0;
      if (this.logError) console.error('Error cancelling: ', err.stack);
      return (_ref2 = this._handler) != null ? typeof _ref2.error === "function" ? _ref2.error(err) : void 0 : void 0;
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
    var _ref2;
    if (this.logError) console.error('Error in socket: ', error);
    if ((_ref2 = this._handler) != null) {
      if (typeof _ref2.error === "function") _ref2.error(error);
    }
    return this.end();
  };

  TdsClient.prototype._socketData = function(data) {
    if (this.logDebug) {
      console.log('Received %d bytes at state', data.length, this.state, data);
    }
    this._stream.append(data);
    if (this._tokenStream != null) {
      return this._handleTokenStream();
    } else {
      return this._handlePacket();
    }
  };

  TdsClient.prototype._getPacketFromType = function(type) {
    switch (type) {
      case TokenStreamPacket.type:
        if (this.state === TdsConstants.statesByName['CONNECTING']) {
          return new PreLoginPacket;
        } else {
          return new TokenStreamPacket;
        }
        break;
      case PreLoginPacket.type:
        return new PreLoginPacket;
      default:
        throw new Error('Unrecognized type: ' + type);
    }
  };

  TdsClient.prototype._handleToken = function() {
    var currentOffset, receivedLoginAck, token, _name, _ref2, _ref3;
    token = null;
    receivedLoginAck = false;
    while (true) {
      this._stream.beginTransaction();
      try {
        currentOffset = this._stream.currentOffset();
        token = this._tokenStream.nextToken(this._stream, this);
        this._tokenStreamRemainingLength -= this._stream.currentOffset() - currentOffset;
        if (this.logDebug) {
          console.log('From %d to %d offset, remaining: ', currentOffset, this._stream.currentOffset(), this._tokenStreamRemainingLength);
        }
        this._stream.commitTransaction();
      } catch (err) {
        if (err instanceof StreamIndexOutOfBoundsError) {
          if (this.logDebug) console.log('Stream incomplete, rolling back');
          this._stream.rollbackTransaction();
          return;
        } else {
          if (this.logError) console.error('Error reading stream: ', err.stack);
          throw err;
        }
      }
      if (this._tokenStreamRemainingLength === 0) {
        this._tokenStream = this._tokenStreamRemainingLength = null;
      }
      if (!this._cancelling || token.type === DoneToken.type) {
        this._cancelling = void 0;
        if ((_ref2 = this._handler) != null) {
          if (typeof _ref2[_name = token.handlerFunction] === "function") {
            _ref2[_name](token);
          }
        }
        if (this.logDebug) console.log('Checking token type: ', token.type);
        switch (token.type) {
          case LoginAckToken.type:
            if (this.state !== TdsConstants.statesByName['LOGGING IN']) {
              throw new Error('Received login ack when not loggin in');
            }
            receivedLoginAck = true;
            break;
          case ColMetaDataToken.type:
            this.colmetadata = token;
        }
      }
      if (!(this._tokenStream != null)) break;
    }
    if (receivedLoginAck) {
      this.state = TdsConstants.statesByName['LOGGED IN'];
      return (_ref3 = this._handler) != null ? typeof _ref3.login === "function" ? _ref3.login() : void 0 : void 0;
    }
  };

  TdsClient.prototype._handlePacket = function() {
    var header, packet, _ref2;
    packet = null;
    this._stream.beginTransaction();
    try {
      header = Packet.retrieveHeader(this._stream, this);
      packet = this._getPacketFromType(header.type);
      if (packet instanceof TokenStreamPacket) {
        if (this.logDebug) console.log('Found token stream packet');
        this._tokenStream = packet;
        this._tokenStreamRemainingLength = header.length - 8;
      } else {
        if (this.logDebug) console.log('Found non token stream packet');
        packet.fromBuffer(this._stream, this);
      }
      this._stream.commitTransaction();
    } catch (err) {
      if (err instanceof StreamIndexOutOfBoundsError) {
        if (this.logDebug) console.log('Stream incomplete, rolling back');
        this._stream.rollbackTransaction();
        return;
      } else {
        if (this.logError) console.error('Error reading stream: ', err.stack);
        throw err;
      }
    }
    if (this._tokenStream != null) {
      return this._handleToken();
    } else {
      if (this.logDebug) {
        console.log('Buffer remaining: ', this._stream.getBuffer());
      }
      if (packet instanceof PreLoginPacket) {
        this.state = TdsConstants.statesByName['CONNECTED'];
        return (_ref2 = this._handler) != null ? typeof _ref2.connect === "function" ? _ref2.connect(packet) : void 0 : void 0;
      } else {
        if (this.logError) console.error('Unrecognized type: ' + packet.type);
        throw new Error('Unrecognized type: ' + packet.type);
      }
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
    if (this.logDebug) {
      console.log('Sending packet: %s at state', packet.name, this.state);
    }
    builder = new BufferBuilder();
    builder = packet.toBuffer(new BufferBuilder(), this);
    buff = builder.toBuffer();
    if (this.logDebug) console.log('Packet size: %d', buff.length);
    return this._socket.write(buff);
  };

  TdsClient.prototype.end = function() {
    var _ref2;
    if (this.logDebug) console.log('Ending socket');
    try {
      this._socket.end();
    } catch (_error) {}
    this._socket = null;
    this.state = TdsConstants.statesByName['INITIAL'];
    return (_ref2 = this._handler) != null ? typeof _ref2.end === "function" ? _ref2.end() : void 0 : void 0;
  };

  return TdsClient;

})();
