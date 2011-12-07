var Packet, TdsConstants;
var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

Packet = require('./packet').Packet;

TdsConstants = require('./tds-constants').TdsConstants;

exports.Login7Packet = (function() {
  var connectionId;

  __extends(Login7Packet, Packet);

  function Login7Packet() {
    Login7Packet.__super__.constructor.apply(this, arguments);
  }

  Login7Packet.type = 0x10;

  Login7Packet.name = 'LOGIN7';

  Login7Packet.prototype.type = 0x10;

  Login7Packet.prototype.name = 'LOGIN7';

  /**
  * The version of TDS to use.
  * Default is TdsConstants.versionsByVersion['7.1.1']
  */

  Login7Packet.prototype.tdsVersion = TdsConstants.versionsByVersion['7.1.1'];

  /**
  * How big the packets should be.
  * Default is 0 (SQL server decides)
  */

  Login7Packet.prototype.packetSize = 0;

  /**
  * The client version.
  * Default is 7
  */

  Login7Packet.prototype.clientProgramVersion = 7;

  /**
  * The client process ID.
  * Default is the current process ID
  */

  Login7Packet.prototype.clientProcessId = process.pid;

  /**
  * The connection ID.
  * Default is 0
  */

  connectionId = 0;

  Login7Packet.prototype.optionFlags1 = 0;

  Login7Packet.prototype.optionFlags2 = 0x03;

  Login7Packet.prototype.typeFlags = 0;

  Login7Packet.prototype.optionFlags3 = 0;

  Login7Packet.prototype.clientTimeZone = 0;

  Login7Packet.prototype.clientLcid = 0;

  Login7Packet.prototype.hostName = require('os').hostname();

  Login7Packet.prototype.domain = '';

  Login7Packet.prototype.userName = '';

  Login7Packet.prototype.password = '';

  Login7Packet.prototype.appName = 'node-tds';

  Login7Packet.prototype.serverName = '';

  Login7Packet.prototype.unused = '';

  Login7Packet.prototype.interfaceLibraryName = 'node-tds';

  Login7Packet.prototype.language = '';

  Login7Packet.prototype.database = '';

  Login7Packet.prototype.clientId = [0, 0, 0, 0, 0, 0];

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
    getPositionAndLength('clientId');
    getPositionAndLength('.ntlm');
    stream.skip(4);
    _results = [];
    for (key in pendingStrings) {
      value = pendingStrings[key];
      str = stream.readUcs2String(value.length);
      if (key.charAt(0 !== '.')) {
        _results.push(this[key] = str);
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  Login7Packet.prototype.toBuffer = function(builder, context) {
    var curPos, length;
    if (this.serverName.length === 0) throw new Error('serverName not specified');
    if (this.userName.length === 0) throw new Error('userName not specified');
    if (this.domain.length > 0) throw new Error('NTLM not yet supported');
    length = 86 + 2 * (this.hostName.length + this.appName.length + this.serverName.length + this.interfaceLibraryName.length + this.language.length + this.database.length);
    builder.appendUInt32LE(length);
    builder.appendUInt32LE(this.tdsVersion);
    builder.appendUInt32LE(this.packetSize);
    builder.appendUInt32LE(this.clientProgramVersion);
    builder.appendUInt32LE(this.clientProcessId);
    builder.appendUInt32LE(this.connectionId);
    builder.appendByte(this.optionFlags1);
    builder.appendByte(this.optionFlags2);
    builder.appendByte(this.typeFlags);
    builder.appendByte(this.optionFlags3);
    builder.appendUInt32LE(this.clientTimeZone);
    builder.appendUInt32LE(this.clientLcid);
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
    builder.appendUInt16LE(this.unused.length);
    curPos += this.unused.length * 2;
    builder.appendUInt16LE(curPos);
    builder.appendUInt16LE(this.interfaceLibraryName.length);
    curPos += this.interfaceLibraryName.length * 2;
    builder.appendUInt16LE(curPos);
    builder.appendUInt16LE(this.language.length);
    curPos += this.language.length * 2;
    builder.appendUInt16LE(curPos);
    builder.appendUInt16LE(this.database.length);
    curPos += this.database.length * 2;
    builder.appendBytes(this.clientId);
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
    var byte, i, ret, _ref;
    ret = new Buffer(this.password, 'ucs2');
    for (i = 0, _ref = this.password.length - 1; 0 <= _ref ? i <= _ref : i >= _ref; 0 <= _ref ? i++ : i--) {
      byte = ret[i];
      ret[i] = ((byte & 0x0f) | (byte >> 4)) ^ 0xA5;
    }
    return ret;
  };

  return Login7Packet;

})();
