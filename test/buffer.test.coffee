assert = require 'assert'

{BufferBuilder} = require '../lib/buffer-builder'
{BufferStream} = require '../lib/buffer-stream'

describe 'BufferBuilder and BufferStream', ->
  it 'should marshal and unmarshal all values properly', (done) ->
    try
      # create builder
      bldr = new BufferBuilder()
      # append values
      bldr.appendBuffer(new Buffer('buff', 'utf8'))
         .appendByte(1)
         .appendBytes([2, 3])
         .appendInt32LE(4)
         .appendUcs2String('ucs2 string')
         .appendAsciiString('ascii string')
         .appendUInt16LE(5)
         .appendUInt32LE(6)
         # write buffer
      buff = bldr.toBuffer()
      assert.equal buff.length, bldr.length
      # create stream
      stream = new BufferStream()
      # append buffer
      stream.append buff
      # start read
      stream.beginTransaction()
      # check values
      assert.equal stream.readBuffer(Buffer.byteLength('buff')).toString('utf8'), 'buff'
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
      # insert values
      bldr.insertByte 7, 0
      bldr.insertUInt16BE 8, 0
      # add to stream
      buff = bldr.toBuffer()
      stream = new BufferStream()
      stream.append buff
      stream.beginTransaction()
      # check inserted
      assert.equal stream.readUInt16BE(), 8
      assert.equal stream.readByte(), 7
      # strange global leak
      delete global.val
      # done
      done()
    catch err
      console.log err.stack
      done err
