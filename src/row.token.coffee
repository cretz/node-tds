{TdsUtils} = require './tds-utils'
{Token} = require './token'

class exports.RowToken extends Token
  
  @type: 0xD1
  @name: 'ROW'
  
  constructor: ->
    @type = 0xD1
    @name = 'ROW'
    @handlerFunction = 'row'
  
  fromBuffer: (stream, context) ->
    @metadata = context.colmetadata
    @values = new Array(@metadata.columns.length)
    index = -1
    for column in @metadata.columns
      val = {}
      switch column.lengthType
        when 'int32LE' then val.length = stream.readInt32LE()
        when 'uint16LE' then val.length = stream.readUInt16LE()
        when 'uint8' then val.length = stream.readByte()
        else val.length = column.length
      if val.length is 0xFFFF then val.length = -1
      val.buffer = stream.readBuffer column.length
      @values[++index] = val

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
        else val.buffer.readUInt8 0
      when 'SmallInt'
        if val.length is 0 then null
        else val.buffer.readUInt16LE 0
      when 'Int'
        if val.length is 0 then null
        else val.buffer.readUInt32LE 0
      when 'BigInt'
        if val.length is 0 then null
        else TdsUtils.bigIntBufferToString val
      # TODO RowVersion/TimeStamp
      when 'Char', 'VarChar'
        if val.length is -1 then null
        else val.buffer.toString 'ascii', 0, val.length
      when 'NChar', 'NVarChar'
        if val.length is -1 then null
        else val.buffer.toString 'ucs2', 0, val.length * 2
      when 'Binary', 'VarBinary'
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
      # TODO when 'Numeric', 'Decimal'
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