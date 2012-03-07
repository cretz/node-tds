{Token} = require './token'
{TdsConstants} = require './tds-constants'

###*
Token for COLMETADATA (0x81)

@spec 2.2.7.4
###
class exports.ColMetaDataToken extends Token
  
  @type: 0x81
  @name: 'COLMETADATA'

  constructor: ->
    @type = 0x81
    @name = 'COLMETADATA'
    @handlerFunction = 'colmetadata'
  
  fromBuffer: (stream, context) ->
    len = stream.readUInt16LE()
    @columns = new Array len
    @columnsByName = {}
    if len isnt 0xFFFF then for i in [0..len - 1]
      @columns[i] = column = 
        index: i
        # userType
        userType: stream.readUInt16LE()
        # flags
        flags: stream.readUInt16LE()
      # more typeInfo work
      typ = stream.readByte()
      column.type = TdsConstants.dataTypesByType[typ]
      if not column.type?
        throw new Error 'Unrecognized column type 0x' + typ.toString 16
      column.isNullable = column.flags & 0x01 isnt 0
      column.isCaseSensitive = column.flags & 0x02 isnt 0
      column.isIdentity = column.flags & 0x10 isnt 0
      column.isWriteable = column.flags & 0x0C isnt 0
      if not column.type.length?
        if column.type.hasScaleWithoutLength
          column.length = column.scale = stream.readByte()
        else 
          switch column.type.lengthType
            when 'int32LE' 
              column.length = stream.readInt32LE()
              column.lengthType = 'int32LE'
            when 'uint16LE'
              column.length = stream.readUInt16LE()
              column.lengthType = 'uint16LE'
            else 
              column.length = stream.readByte()
              column.lengthType = 'uint8'
        if column.type.lengthSubstitutes?
          column.type = TdsConstants.dataTypesByType[column.type.lengthSubstitutes[column.length]]
          if not column.type? then throw new Error 'Unable to find length substitute ' + column.length
        if column.type.hasCollation
          column.collation = stream.readBytes 5
        else if column.type.hasScaleAndPrecision
          column.scale = stream.readByte()
          column.precision = stream.readByte()
      else
        column.length = column.type.length
      # null?
      if column.length is 0xFFFF then column.length = -1
      # tableName
      if column.type.hasTableName
        column.tableName = stream.readUcs2String stream.readUInt16LE()
      # colName
      column.name = stream.readUcs2String stream.readByte()
      @columnsByName[column.name] = column

  getColumn: (column) ->
    if typeof column is 'string'
      @columnsByName[column]
    else
      @columns[column]
