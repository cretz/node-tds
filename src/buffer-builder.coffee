class BufferBuilder
  
  _values: []
  
  _length: 0
  
  appendByte: (byte) ->
    @_length++
    @_values.push type: 'byte', value: byte
    @
    
  appendInt: (int) ->
    @_length += 4
    @_values.push type: 'int', value: int
    @
    
  toBuffer: ->
    buff = new Buffer @_length
    offset = 0
    for value in values
      switch value.type
        when 'byte'
          buff.set offset, value.value
          offset++
        when 'int'
          buff.writeInt32BE value.value, offset
          offset += 4
        else
          throw new Error 'Unrecognized type: ' + value.type

