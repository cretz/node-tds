/**
Builder for buffers. Basically allows building a buffer
but the buffer isn't created until toBuffer is called.
*/
exports.BufferBuilder = (function() {

  BufferBuilder.getUcs2StringLength = function(string) {
    return string.length * 2;
  };

  function BufferBuilder() {
    this._values = [];
    this.length = 0;
  }

  BufferBuilder.prototype.appendBuffer = function(buffer) {
    this.length += buffer.length;
    this._values.push({
      type: 'buffer',
      value: buffer
    });
    return this;
  };

  BufferBuilder.prototype.appendByte = function(byte) {
    this.length++;
    this._values.push({
      type: 'byte',
      value: byte
    });
    return this;
  };

  BufferBuilder.prototype.appendBytes = function(bytes) {
    this.length += bytes.length;
    this._values.push({
      type: 'byte array',
      value: bytes
    });
    return this;
  };

  BufferBuilder.prototype.appendInt32LE = function(int) {
    this.length += 4;
    this._values.push({
      type: 'int32LE',
      value: int
    });
    return this;
  };

  BufferBuilder.prototype.appendString = function(string, encoding) {
    var len;
    len = Buffer.byteLength(string, encoding);
    this.length += len;
    this._values.push({
      type: 'string',
      encoding: encoding,
      value: string,
      length: len
    });
    return this;
  };

  BufferBuilder.prototype.appendUcs2String = function(string) {
    return this.appendString(string, 'ucs2');
  };

  BufferBuilder.prototype.appendAsciiString = function(string) {
    return this.appendString(string, 'ascii');
  };

  BufferBuilder.prototype.appendUInt16LE = function(int) {
    this.length += 2;
    this._values.push({
      type: 'uint16LE',
      value: int
    });
    return this;
  };

  BufferBuilder.prototype.appendUInt32LE = function(int) {
    this.length += 4;
    this._values.push({
      type: 'uint32LE',
      value: int
    });
    return this;
  };

  BufferBuilder.prototype.insertByte = function(byte, position) {
    this.length++;
    this._values.splice(position, 0, {
      type: 'byte',
      value: byte
    });
    return this;
  };

  BufferBuilder.prototype.insertUInt16BE = function(int, position) {
    this.length += 2;
    this._values.splice(position, 0, {
      type: 'uint16BE',
      value: int
    });
    return this;
  };

  BufferBuilder.prototype.insertUInt16LE = function(int, position) {
    this.length += 2;
    this._values.splice(position, 0, {
      type: 'uint16LE',
      value: int
    });
    return this;
  };

  BufferBuilder.prototype.insertUInt32LE = function(int, position) {
    this.length += 4;
    this._values.splice(position, 0, {
      type: 'uint32LE',
      value: int
    });
    return this;
  };

  BufferBuilder.prototype.toBuffer = function() {
    var buff, byte, offset, value, _i, _j, _len, _len2, _ref, _ref2;
    buff = new Buffer(this.length);
    offset = 0;
    _ref = this._values;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      value = _ref[_i];
      switch (value.type) {
        case 'buffer':
          value.value.copy(buff, offset);
          offset += value.value.length;
          break;
        case 'byte':
          buff.set(offset, value.value);
          offset++;
          break;
        case 'byte array':
          _ref2 = value.value;
          for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
            byte = _ref2[_j];
            buff.set(offset, byte);
            offset++;
          }
          break;
        case 'int32LE':
          buff.writeInt32LE(value.value, offset);
          offset += 4;
          break;
        case 'string':
          buff.write(value.value, offset, value.length, value.encoding);
          offset += value.length;
          break;
        case 'uint16BE':
          buff.writeUInt16BE(value.value, offset);
          offset += 2;
          break;
        case 'uint16LE':
          buff.writeUInt16LE(value.value, offset);
          offset += 2;
          break;
        case 'uint32LE':
          buff.writeUInt32LE(value.value, offset);
          offset += 4;
          break;
        default:
          throw new Error('Unrecognized type: ' + value.type);
      }
    }
    return buff;
  };

  return BufferBuilder;

})();
