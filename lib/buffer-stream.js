/**
Streaming buffer reader. This allows you to mark the beginning
of the read, and read individual pieces. If the underlying buffer
isn't big enough, a StreamIndexOutOfBoundsError is thrown.
*/
var __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

exports.BufferStream = (function() {

  function BufferStream() {
    this._offset = 0;
  }

  BufferStream.prototype.append = function(buffer) {
    var newBuffer;
    if (!(this._buffer != null)) {
      return this._buffer = buffer;
    } else {
      newBuffer = new Buffer(this._buffer.length + buffer.length);
      this._buffer.copy(newBuffer);
      buffer.copy(newBuffer, this._buffer.length);
      return this._buffer = newBuffer;
    }
  };

  BufferStream.prototype.getBuffer = function() {
    return this._buffer;
  };

  BufferStream.prototype.beginTransaction = function() {
    return this._offsetStart = this._offset;
  };

  BufferStream.prototype.commitTransaction = function() {
    this._offsetStart = null;
    this._buffer = this._buffer.slice(this._offset);
    return this._offset = 0;
  };

  BufferStream.prototype.rollbackTransaction = function() {
    this._offset = this._offsetStart;
    return this._offsetStart = null;
  };

  BufferStream.prototype.assertBytesAvailable = function(amountNeeded) {
    if (amountNeeded + this._offset > this._buffer.length) {
      console.log('Need %d, length %d', amountNeeded + this._offset, this._buffer.length);
      throw new BufferStream.StreamIndexOutOfBoundsError('Index out of bounds');
    }
  };

  BufferStream.prototype.currentOffset = function() {
    return this._offset - this._offsetStart;
  };

  /**
  * Overrides the current transaction's offset with
  * the given one. This doesn't validate
  * 
  * @param {number} offset The offset to set, where 0 is
  *   the start of the transaction
  */

  BufferStream.prototype.overrideOffset = function(offset) {
    return this._offset = this._offsetStart + offset;
  };

  BufferStream.prototype.peekByte = function() {
    this.assertBytesAvailable(1);
    return this._buffer.get(this._offset);
  };

  BufferStream.prototype.readBuffer = function(length) {
    var ret;
    this.assertBytesAvailable(length);
    ret = this._buffer.slice(this._offset, this._offset + length);
    this._offset += length;
    return ret;
  };

  BufferStream.prototype.readByte = function() {
    var ret;
    this.assertBytesAvailable(1);
    ret = this._buffer.get(this._offset);
    this._offset++;
    return ret;
  };

  BufferStream.prototype.readBytes = function(length) {
    var i, ret, _ref;
    this.assertBytesAvailable(length);
    ret = [];
    for (i = 0, _ref = length - 1; 0 <= _ref ? i <= _ref : i >= _ref; 0 <= _ref ? i++ : i--) {
      ret.push(this._buffer.get(this._offset));
      this._offset++;
    }
    return ret;
  };

  BufferStream.prototype.readInt32LE = function() {
    var ret;
    this.assertBytesAvailable(4);
    ret = this._buffer.readInt32LE(this._offset);
    this._offset += 4;
    return ret;
  };

  BufferStream.prototype.readString = function(lengthInBytes, encoding) {
    var ret;
    this.assertBytesAvailable(lengthInBytes);
    ret = this._buffer.toString(encoding, this._offset, this._offset + lengthInBytes);
    this._offset += lengthInBytes;
    return ret;
  };

  /**
  * Does not move the offset
  */

  BufferStream.prototype.readStringFromIndex = function(index, lengthInBytes, encoding) {
    if (index + this._offsetStart >= this._buffer.length) {
      throw new BufferStream.StreamIndexOutOfBoundsError('Index out of bounds');
    }
    return this._buffer.toString(encoding, index + this._offsetStart, index + this._offsetStart + lengthInBytes);
  };

  BufferStream.prototype.readUcs2String = function(length) {
    return this.readString(length * 2, 'ucs2');
  };

  BufferStream.prototype.readAsciiString = function(length) {
    return this.readString(length, 'ascii');
  };

  /**
  * Does not move the offset
  */

  BufferStream.prototype.readUcs2StringFromIndex = function(index, length) {
    return this.readStringFromIndex(index, length * 2, 'ucs2');
  };

  BufferStream.prototype.readUInt16BE = function() {
    var ret;
    this.assertBytesAvailable(2);
    ret = this._buffer.readUInt16BE(this._offset);
    this._offset += 2;
    return ret;
  };

  BufferStream.prototype.readUInt16LE = function() {
    var ret;
    this.assertBytesAvailable(2);
    ret = this._buffer.readUInt16LE(this._offset);
    this._offset += 2;
    return ret;
  };

  BufferStream.prototype.readUInt32LE = function() {
    var ret;
    this.assertBytesAvailable(4);
    ret = this._buffer.readUInt32LE(this._offset);
    this._offset += 4;
    return ret;
  };

  BufferStream.prototype.skip = function(length) {
    this.assertBytesAvailable(length);
    return this._offset += length;
  };

  BufferStream.StreamIndexOutOfBoundsError = exports.StreamIndexOutOfBoundsError = (function(_super) {

    __extends(StreamIndexOutOfBoundsError, _super);

    StreamIndexOutOfBoundsError.prototype.name = 'StreamIndexOutOfBoundsError';

    function StreamIndexOutOfBoundsError(message) {
      this.message = message;
      this.stack = (new Error).stack;
    }

    return StreamIndexOutOfBoundsError;

  })(Error);

  return BufferStream;

})();
