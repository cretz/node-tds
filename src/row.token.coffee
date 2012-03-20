{TdsUtils} = require './tds-utils'
{Token} = require './token'

_PLP_NULL = new Buffer [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF]

###*
Token for ROW (0xD1)

@spec 2.2.7.17
###
class exports.RowToken extends Token
  
  @type: 0xD1
  @name: 'ROW'
  
  constructor: ->
    @type = 0xD1
    @name = 'ROW'
    @handlerFunction = 'row'
  
  fromBuffer: (stream, context) ->
    @_context = context
    @metadata = context.colmetadata
    @values = new Array(@metadata.columns.length)
    for column, index in @metadata.columns
      val = {}
      # ignore pointer
      if column.type.hasTextPointer
        len = stream.readByte()
        if len isnt 0 then stream.skip len + 8
        else val.length = -1
        context.debug 'Val: ', val
      if column.length isnt 0xFFFF and val.length isnt -1
        switch column.lengthType
          when 'int32LE' then val.length = stream.readInt32LE()
          when 'uint16LE' then val.length = stream.readUInt16LE()
          when 'uint8' then val.length = stream.readByte()
          else val.length = column.length
      else if val.length isnt -1
        # max length stuff
        switch column.type.sqlType
          when 'Char', 'VarChar', 'NChar', 'NVarChar', 'Binary', 'VarBinary'
            # grab the entire buffer
            top = stream.readBuffer 8
            if top.equals _PLP_NULL then val.length = -1
            else
              # skip expected length validation for now
              chunkLength = stream.readUInt32LE()
              val.length = 0
              chunks = []
              while chunkLength isnt 0
                val.length += chunkLength
                chunks.push stream.readBuffer(chunkLength)
                chunkLength = stream.readUInt32LE()
              val.buffer = new Buffer val.length
              pos = 0
              for chunk in chunks
                chunk.copy val.buffer, pos, 0
                pos += chunk.length
              # the length is half if it's unicode
              if column.type.sqlType is 'NChar' or column.type.sqlType is 'NVarChar'
                val.length /= 2
          else val.length = column.length
      if val.length is 0 and column.type.emptyPossible
        val.buffer = new Buffer 0
      else if val.length > 0
        val.buffer = stream.readBuffer val.length
      @values[index] = val

  isNull: (column) ->
    col = @metadata.getColumn column
    if not col? then throw new Error 'Column ' + column + ' not found'
    if col.type.emptyPossible then @values[col.index].length is -1
    else @values[col.index] is 0

  getValueLength: (column) ->
    col = @metadata.getColumn column
    if not col? then throw new Error 'Column ' + column + ' not found'
    @values[col.index].length

  getValue: (column) ->
    col = @metadata.getColumn column
    if not col? then throw new Error 'Column ' + column + ' not found'
    val = @values[col.index]
    switch col.type.sqlType
      when 'Null'
        null
      when 'Bit', 'TinyInt'
        if val.length is 0 then null
        else val.buffer.readInt8 0
      when 'SmallInt'
        if val.length is 0 then null
        else val.buffer.readInt16LE 0
      when 'Int'
        if val.length is 0 then null
        else val.buffer.readInt32LE 0
      when 'BigInt'
        if val.length is 0 then null
        else TdsUtils.bigIntBufferToString val.buffer
      # TODO RowVersion/TimeStamp
      when 'Char', 'VarChar', 'Text'
        if val.length is -1 then null
        else val.buffer.toString 'ascii', 0, val.length
      when 'NChar', 'NVarChar', 'NText'
        if val.length is -1 then null
        else val.buffer.toString 'ucs2', 0, val.length * 2
      when 'Binary', 'VarBinary', 'Image'
        if col.length is -1 then null
        else val.buffer
      # TODO when 'SmallMoney'
      # TODO when 'Money'
      when 'Real'
        if val.length is 0 then null
        else val.buffer.readFloatLE 0
      when 'Float'
        if val.length is 0 then null
        else val.buffer.readDoubleLE 0
      when 'Numeric', 'Decimal'
        if val.length is 0 then null
        else
          sign = if val.buffer.readUInt8(0) is 1 then 1 else -1
          nums = []
          switch val.length - 1
            when 4 then nums = [val.buffer.readUInt32LE(1)]
            when 8
              nums = [val.buffer.readUInt32LE(1), val.buffer.readUInt32LE(5)]
            when 12
              nums = [
                val.buffer.readUInt32LE(1), 
                val.buffer.readUInt32LE(5),
                val.buffer.readUInt32LE(9)
              ]
            when 16
              nums = [
                val.buffer.readUInt32LE(1),
                val.buffer.readUInt32LE(5),
                val.buffer.readUInt32LE(9),
                val.buffer.readUInt32LE(13)
              ]
            else throw new Error 'Unknown numeric size: ' + (val.length - 1)
          retVal = 0
          for num, i in nums
            retVal += Math.pow(0x100000000, i) * num
          retVal *= sign
          retVal /= Math.pow 10, col.scale
      when 'UniqueIdentifier'
        if val.length is 0 then null
        else val.buffer
      when 'SmallDateTime'
        if val.length is 0 then null
        else @_readSmallDateTime val.buffer
      when 'DateTime'
        if val.length is 0 then null
        else @_readDateTime val.buffer
      when 'Date'
        if val.length is 0 then null
        else @_readDate val.buffer
      # TODO when 'Time'
      # TODO when 'DateTime2'
      # TODO when 'DateTimeOffset'
      else
        throw new Error 'Unrecognized type ' + col.type.name

  getBuffer: (column) ->
    col = @metadata.getColumn column
    if not col? then throw new Error 'Column ' + column + ' not found'
    @values[col.index].buffer

  toObject: ->
    ret = {}
    for column in @metadata.columns
      ret[column.name] = getValue column.index
    ret
      
  _readSmallDateTime: (buffer) ->
    date = new Date 1900, 0, 1
    date.setDate date.getDate() + buffer.readUInt16LE 0
    date.setMinutes date.getMinutes() + buffer.readUInt16LE 2
    date

  _readDateTime: (buffer) ->
    date = new Date 1900, 0, 1
    date.setDate date.getDate() + buffer.readInt32LE 0
    date.setMilliseconds date.getMilliseconds() + 
      (buffer.readInt32LE(4) * (10 / 3.0))
    date

  _readDate: (buffer) ->
    throw new Error 'Not implemented'
    
