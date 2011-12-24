var Packet, TdsConstants;
var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

Packet = require('./packet').Packet;

TdsConstants = require('./tds-constants').TdsConstants;

exports.Login7Packet = (function() {

  __extends(Login7Packet, Packet);

  Login7Packet.type = 0x10;

  Login7Packet.name = 'LOGIN7';

  function Login7Packet() {
    this.type = 0x10;
    this.name = 'LOGIN7';
  }

  Login7Packet.prototype.fromBuffer = function(stream, context) {
    var getPositionAndLength, key, length, pendingStrings, str, value, _results;
    length = stream.readUInt32LE();
    stream.assertBytesAvailable(length - 4);
    this.tdsVersion = stream.readUInt32LE();
    this.packetSize = stream.readUInt32LE();
    this.clientProgramVersion = stream.readUInt32LE();
    this.clientProcessId = stream.readUInt32LE();
    this.connectionId = stream.readUInt32LE();
    this.optionFlags1 = stream.readByte();
    this.optionFlags2 = stream.readByte();
    this.typeFlags = stream.readByte();
    this.optionFlags3 = stream.readByte();
    this.clientTimeZone = stream.readUInt32LE();
    this.clientLcid = stream.readUInt32LE();
    pendingStrings = {};
    getPositionAndLength = function(name) {
      return pendingStrings[name] = {
        pos: stream.readUInt16LE(),
        length: stream.readUInt16LE()
      };
    };
    getPositionAndLength('hostName');
    getPositionAndLength('userName');
    getPositionAndLength('.password');
    getPositionAndLength('appName');
    getPositionAndLength('serverName');
    getPositionAndLength('unused');
    getPositionAndLength('interfaceLibraryName');
    getPositionAndLength('language');
    getPositionAndLength('database');
    this.clientId = stream.readBytes(6);
    getPositionAndLength('.ntlm');
    stream.skip(4);
    _results = [];
    for (key in pendingStrings) {
      value = pendingStrings[key];
      if (context.logDebug) {
        console.log('Reading %s at %d of length %d', key, value.pos, value.length);
      }
      str = stream.readUcs2String(value.length);
      if (context.logDebug) console.log('Read %s: %s', key, str);
      if (key.charAt(0 !== '.')) {
        _results.push(this[key] = str);
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  Login7Packet.prototype.toBuffer = function(builder, context) {
    var curPos, length, _ref, _ref10, _ref11, _ref12, _ref13, _ref14, _ref15, _ref16, _ref17, _ref18, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7, _ref8, _ref9;
    if (!(this.serverName != null) || this.serverName.length === 0) {
      throw new Error('serverName not specified');
    }
    if (!(this.userName != null) || this.userName.length === 0) {
      throw new Error('userName not specified');
    }
    if ((this.domain != null) && this.domain.length > 0) {
      throw new Error('NTLM not yet supported');
    }
    if ((_ref = this.hostName) == null) this.hostName = require('os').hostname();
    if ((_ref2 = this.password) == null) this.password = '';
    if ((_ref3 = this.appName) == null) this.appName = 'node-tds';
    if ((_ref4 = this.interfaceLibraryName) == null) {
      this.interfaceLibraryName = 'node-tds';
    }
    if ((_ref5 = this.language) == null) this.language = '';
    if ((_ref6 = this.database) == null) this.database = '';
    length = 86 + 2 * (this.hostName.length + this.userName.length + this.password.length + this.appName.length + this.serverName.length + this.interfaceLibraryName.length + this.language.length + this.database.length);
    builder.appendUInt32LE(length);
    builder.appendUInt32LE((_ref7 = this.tdsVersion) != null ? _ref7 : TdsConstants.versionsByVersion['7.1.1']);
    builder.appendUInt32LE((_ref8 = this.packetSize) != null ? _ref8 : 0);
    builder.appendUInt32LE((_ref9 = this.clientProgramVersion) != null ? _ref9 : 7);
    builder.appendUInt32LE((_ref10 = this.clientProcessId) != null ? _ref10 : process.pid);
    builder.appendUInt32LE((_ref11 = this.connectionId) != null ? _ref11 : 0);
    builder.appendByte((_ref12 = this.optionFlags1) != null ? _ref12 : 0);
    builder.appendByte((_ref13 = this.optionFlags2) != null ? _ref13 : 0x03);
    builder.appendByte((_ref14 = this.typeFlags) != null ? _ref14 : 0);
    builder.appendByte((_ref15 = this.optionFlags3) != null ? _ref15 : 0);
    builder.appendUInt32LE((_ref16 = this.clientTimeZone) != null ? _ref16 : 0);
    builder.appendUInt32LE((_ref17 = this.clientLcid) != null ? _ref17 : 0);
    curPos = 86;
    builder.appendUInt16LE(curPos);
    builder.appendUInt16LE(this.hostName.length);
    curPos += this.hostName.length * 2;
    builder.appendUInt16LE(curPos);
    builder.appendUInt16LE(this.userName.length);
    curPos += this.userName.length * 2;
    builder.appendUInt16LE(curPos);
    builder.appendUInt16LE(this.password.length);
    curPos += this.password.length * 2;
    builder.appendUInt16LE(curPos);
    builder.appendUInt16LE(this.appName.length);
    curPos += this.appName.length * 2;
    builder.appendUInt16LE(curPos);
    builder.appendUInt16LE(this.serverName.length);
    curPos += this.serverName.length * 2;
    builder.appendUInt16LE(curPos);
    builder.appendUInt16LE(0);
    builder.appendUInt16LE(curPos);
    builder.appendUInt16LE(this.interfaceLibraryName.length);
    curPos += this.interfaceLibraryName.length * 2;
    builder.appendUInt16LE(curPos);
    builder.appendUInt16LE(this.language.length);
    curPos += this.language.length * 2;
    builder.appendUInt16LE(curPos);
    builder.appendUInt16LE(this.database.length);
    curPos += this.database.length * 2;
    builder.appendBytes((_ref18 = this.clientId) != null ? _ref18 : [0, 0, 0, 0, 0, 0]);
    builder.appendUInt16LE(curPos);
    builder.appendUInt16LE(0);
    builder.appendUInt32LE(length);
    builder.appendUcs2String(this.hostName);
    builder.appendUcs2String(this.userName);
    builder.appendBuffer(this._encryptPass());
    builder.appendUcs2String(this.appName);
    builder.appendUcs2String(this.serverName);
    builder.appendUcs2String(this.interfaceLibraryName);
    builder.appendUcs2String(this.language);
    builder.appendUcs2String(this.database);
    return this.insertPacketHeader(builder, context);
  };

  Login7Packet.prototype._encryptPass = function() {
    var i, ret, _ref;
    ret = new Buffer(this.password, 'ucs2');
    for (i = 0, _ref = ret.length - 1; 0 <= _ref ? i <= _ref : i >= _ref; 0 <= _ref ? i++ : i--) {
      ret[i] = (((ret[i] & 0x0f) << 4) | (ret[i] >> 4)) ^ 0xA5;
    }
    return ret;
  };

  return Login7Packet;

})();
