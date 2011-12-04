assert = require 'assert'

{BufferBuilder} = require '../lib/buffer-builder'
{BufferStream} = require '../lib/buffer-stream'

describe 'BufferBuilder and BufferStream', ->
  it 'should marshal and unmarshal all values properly', (done) ->
    try
      bldr = new BufferBuilder()
      bldr.appendByte(1)
         .appendBytes([2, 3])
         .appendInt32LE(4)
         .appendUcs2String('ucs2 string')
         .appendAsciiString('ascii string')
         .appendUInt16LE(5)
         .appendUInt32LE(6)
      buff = bldr.toBuffer()
      stream = new BufferStream()
      stream.append buff
      stream.beginTransaction()
      assert.equal stream.readByte(), 1
      bytes = stream.readBytes(2)
      assert.equal bytes.length, 2
      assert.equal bytes[0], 2
      assert.equal bytes[1], 3
      assert.equal stream.readInt32LE(), 4
      assert.equal stream.readUcs2String(11), 'ucs2 string'
      assert.equal stream.readAsciiString(12), 'ascii string'
      assert.equal stream.readUInt16LE(), 5
      assert.equal stream.readUInt32LE(), 6
      assert.equal stream.currentOffset(), buff.length
      done()
    catch err
      console.log err.stack
      done err
