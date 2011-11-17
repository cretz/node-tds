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
    
  _assertBytesAvailable: (amountNeeded) ->
    if amountNeeded + @_offset > @_buffer.length
      throw new StreamIndexOutOfBoundsError
      
  readByte: ->
    @_assertBytesAvailable 1
    ret = @_buffer.get offset
    offset++
    ret

class StreamIndexOutOfBoundsError extends Error
