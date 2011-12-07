var Packet;
var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

Packet = require('./packet').Packet;

exports.PreLoginPacket = (function() {

  __extends(PreLoginPacket, Packet);

  function PreLoginPacket() {
    PreLoginPacket.__super__.constructor.apply(this, arguments);
  }

  PreLoginPacket.type = 0x12;

  PreLoginPacket.name = 'PRELOGIN';

  PreLoginPacket.prototype.type = 0x12;

  PreLoginPacket.prototype.name = 'PRELOGIN';

  PreLoginPacket.prototype.version = [0x08, 0x00, 0x01, 0x55, 0x00, 0x00];

  PreLoginPacket.prototype.encryption = 2;

  PreLoginPacket.prototype.instanceName = '';

  PreLoginPacket.prototype.threadId = process.pid;

  PreLoginPacket.prototype.fromBuffer = function(stream, context) {
    var pendingValue, pendingValues, _i, _len, _results;
    pendingValues = [];
    console.log('current offset: ' + stream.currentOffset());
    while (stream.readByte() !== 0xFF) {
      stream.overrideOffset(stream.currentOffset() - 1);
      pendingValues.push({
        type: stream.readUInt16LE(),
        offset: stream.readUInt16LE(),
        length: stream.readByte()
      });
    }
    _results = [];
    for (_i = 0, _len = pendingValues.length; _i < _len; _i++) {
      pendingValue = pendingValues[_i];
      switch (pendingValue.type) {
        case 0:
          _results.push(this.version = stream.readBytes(6));
          break;
        case 1:
          _results.push(this.encryption = stream.readByte());
          break;
        case 2:
          this.instanceName = stream.readAsciiString(pendingValue.length - 1);
          _results.push(stream.skip(1));
          break;
        case 3:
          _results.push(this.threadId = stream.readUInt32LE());
          break;
        default:
          _results.push(stream.skip(pendingValue.length));
      }
    }
    return _results;
  };

  PreLoginPacket.prototype.toBuffer = function(builder, context) {
    var _ref, _ref2;
    if (this.version.length !== 6) throw new Error('Invalid version length');
    builder.appendUInt16LE(0);
    builder.appendUInt16LE(21);
    builder.appendByte(6);
    builder.appendUInt16LE(1);
    builder.appendUInt16LE(27);
    builder.appendByte(1);
    if ((_ref = this.instanceName) == null) this.instanceName = '';
    builder.appendUInt16LE(2);
    builder.appendUInt16LE(28);
    builder.appendByte(this.instanceName.length + 1);
    if ((_ref2 = this.threadId) == null) this.threadId = 0;
    builder.appendUInt16LE(3);
    builder.appendUInt16LE(this.instanceName.length + 29);
    builder.appendByte(4);
    builder.appendByte(0xFF);
    builder.appendBytes(this.version);
    builder.appendByte(this.encryption);
    builder.appendAsciiString(this.instanceName).appendByte(0);
    builder.appendUInt32LE(this.threadId);
    return this.insertPacketHeader(builder, context);
  };

  return PreLoginPacket;

})();
