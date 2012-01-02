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
    @columns = context.columns
    @columnsByName = context.columnsByName
    @values = new Array(context.columns.length)
    index = -1
    for column in context.columns
      @values[++index] = stream.readBuffer(column.length) 

  getColumn: (column) ->
    if typeof column is string
      @columnsByName[column]
    else
      @columns[column]

  getValue: (column) ->
    col = @getColumn column
    if not col? then throw new Error 'Column ' + column + ' not found'
    val = @values[col.index]
    switch col.type.name
      when 'Null'
        null
      when 'Bit', 'TinyInt'
        if val.length is 0 then null
        else val.readUInt8 0
      when 'SmallInt'
        if val.length is 0 then null
        else val.readUInt16LE 0
      when 'Int'
        if val.length is 0 then null
        else val.readUInt32LE 0
      when 'BigInt'
        if val.length is 0 then null
        else TdsUtils.bigIntBufferToString val
      # TODO RowVersion/TimeStamp
      when 'Char', 'VarChar'
        if col.length is -1 then null
        else val.toString 'ascii'
      when 'NChar', 'NVarChar'
        if col.length is -1 then null
        else val.toString 'ucs2'
      when 'Binary', 'VarBinary'
        if col.length is -1 then null
        else val
      # TODO when 'SmallMoney'
      # TODO when 'Money'
      when 'Real'
        if val.length is 0 then null
        else val.readFloatLE 0
      when 'Float'
        if val.length is 0 then null
        else val.readDoubleLE 0
      # TODO when 'Numeric', 'Decimal'
      when 'UniqueIdentifier'
        if val.length is 0 then null
        else val
      when 'SmallDateTime'
        if val.length is 0 then null
        else @_readSmallDateTime val
      when 'DateTime'
        if val.length is 0 then null
        else @_readDateTime val
      
  _readSmallDateTime: (buffer) ->
    date = new Date 1900, 0, 1
    date.setDate date.getDate() + buffer.readUInt16LE()
    date.setMinutes date.getMinutes() + buffer.readUInt16LE()
    date

  _readDateTime: (buffer) ->
    date = new Date 1900, 0, 1
    date.setDate value.getDate() + buffer.readInt32LE()
    date.setMilliseconds value.getMilliseconds() + 
      (buffer.readInt32LE() * (10 / 3.0))
    date