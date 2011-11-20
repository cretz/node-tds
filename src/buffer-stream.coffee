class BufferStream
  
  _buffer: null
  
  _offset: 0
  
  _offsetStart: null
  
  append: (buffer) ->
    if @_buffer?
      @_buffer = buffer
    else
      newBuffer = new Buffer @_buffer.length + buffer.length
      @_buffer.copy newBuffer
      buffer.copy newBuffer, @_buffer.length
      @_buffer = newBuffer
      
  getBuffer: ->
    @_buffer
    
  beginTransaction: ->
    @_offsetStart = @_offset
    
  commitTransaction: ->
    @_offsetStart = null
    @_buffer = @_buffer.slice @_offset
    @_offset = 0
    
  rollbackTransaction: ->
    @_offset = @_offsetStart
    @_offsetStart = null
    
  assertBytesAvailable: (amountNeeded) ->
    if amountNeeded + @_offset >= @_buffer.length
      throw new StreamIndexOutOfBoundsError
      
  currentOffset: -> @_offset - @_offsetStart
    
  ###*
  * Overrides the current transaction's offset with
  * the given one. This doesn't validate
  * 
  * @param {number} offset The offset to set, where 0 is
  *   the start of the transaction
  ###  
  overrideOffset: (offset) ->
    @_offset = @_offsetStart + offset
      
  # please keep read methods in alphabetical order
      
  readByte: ->
    @assertBytesAvailable 1
    ret = @_buffer.get @_offset
    @_offset++
    ret
    
  readBytes: (length) ->
    @assertBytesAvailable length
    ret = []
    for i in [0..length - 1]
      ret.push @_buffer.get @_offset
      @_offset++
    ret
    
  readInt32LE: ->
    @assertBytesAvailable 4
    ret = @_buffer.readInt32LE @_offset
    @_offset += 4
    ret
    
  readString: (lengthInBytes, encoding) ->
    @assertBytesAvailable lengthInBytes
    ret = @_buffer.toString encoding, @_offset, @_offset + lengthInBytes
    @_offset += lengthInBytes
    ret
    
  ###*
  * Does not move the offset
  ###
  readStringFromIndex: (index, lengthInBytes, encoding) ->
    if index + @_offsetStart >= @_buffer.length
      throw new StreamIndexOutOfBoundsError
    @_buffer.toString encoding, index + @_offsetStart, index + @_offsetStart + lengthInBytes
    
  readUcs2String: (length) ->
    @readString length * 2, 'ucs2'
    
  readAsciiString: (length) ->
    @readString length, 'ascii'
    
  ###*
  * Does not move the offset
  ###
  readUcs2StringFromIndex: (index, length) ->
    @readStringFromIndex index, length * 2, 'ucs2'
  
  readUInt16LE: ->
    @assertBytesAvailable 2
    ret = @_buffer.readUInt16LE offset
    offset += 2
    ret
    
  readUInt32LE: ->
    @assertBytesAvailable 4
    ret = @_buffer.readUInt32LE offset
    offset += 4
    ret
    
  skip: (length) ->
    @assertBytesAvailable length
    offset += length

class StreamIndexOutOfBoundsError extends Error
