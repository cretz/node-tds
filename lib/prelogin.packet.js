var Packet,
  __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

Packet = require('./packet').Packet;

/**
Packet for PRELOGIN (0x12)

@spec 2.2.6.4
*/

exports.PreLoginPacket = (function(_super) {

  __extends(PreLoginPacket, _super);

  PreLoginPacket.type = 0x12;

  PreLoginPacket.name = 'PRELOGIN';

  function PreLoginPacket() {
    this.type = 0x12;
    this.name = 'PRELOGIN';
  }

  PreLoginPacket.prototype.fromBuffer = function(stream, context) {
    var pendingValue, pendingValues, val, _i, _len, _results;
    pendingValues = [];
    while (stream.readByte() !== 0xFF) {
      stream.overrideOffset(stream.currentOffset() - 1);
      pendingValues.push({
        type: stream.readUInt16LE(),
        offset: stream.readUInt16LE(),
        length: stream.readByte()
      });
      if (context.logDebug) {
        val = pendingValues[pendingValues.length - 1];
        console.log('Added pending value type: %d, offset: %d, length: %d', val.type, val.offset, val.length);
      }
    }
    _results = [];
    for (_i = 0, _len = pendingValues.length; _i < _len; _i++) {
      pendingValue = pendingValues[_i];
      switch (pendingValue.type) {
        case 0:
          this.version = stream.readBytes(6);
          if (context.logDebug) {
            _results.push(console.log('Version: ', this.version));
          } else {
            _results.push(void 0);
          }
          break;
        case 1:
          this.encryption = stream.readByte();
          if (context.logDebug) {
            _results.push(console.log('Encryption: ', this.encryption));
          } else {
            _results.push(void 0);
          }
          break;
        case 2:
          if (context.logDebug) {
            console.log('Reading instance name of length: %d', pendingValue.length);
          }
          this.instanceName = stream.readAsciiString(pendingValue.length - 1);
          stream.skip(1);
          if (context.logDebug) {
            _results.push(console.log('Instance name: ', this.instanceName));
          } else {
            _results.push(void 0);
          }
          break;
        case 3:
          if (context.logDebug) {
            _results.push(console.log('Ignoring thread ID: '));
          } else {
            _results.push(void 0);
          }
          break;
        default:
          _results.push(stream.skip(pendingValue.length));
      }
    }
    return _results;
  };

  PreLoginPacket.prototype.toBuffer = function(builder, context) {
    if (this.version == null) this.version = [0x08, 0x00, 0x01, 0x55, 0x00, 0x00];
    if (this.version.length !== 6) throw new Error('Invalid version length');
    builder.appendUInt16LE(0);
    builder.appendUInt16LE(21);
    builder.appendByte(6);
    if (this.encryption == null) this.encryption = 2;
    builder.appendUInt16LE(1);
    builder.appendUInt16LE(27);
    builder.appendByte(1);
    if (this.instanceName == null) this.instanceName = '';
    builder.appendUInt16LE(2);
    builder.appendUInt16LE(28);
    builder.appendByte(this.instanceName.length + 1);
    if (this.threadId == null) this.threadId = process.pid;
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

})(Packet);
