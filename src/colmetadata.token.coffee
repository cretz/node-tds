{Token} = require './token'
{TdsConstants} = require './tds-constants'

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
    if len isnt 0xFFFF then for i in [0..len - 1]
      @columns[i] = column = 
        # userType
        userType: stream.readUInt16LE()
        # flags
        flags: stream.readUInt16LE()
        # typeInfo
        type: stream.readByte()
      # more typeInfo work
      column.type = TdsConstants.dataTypesByType[column.type]
      if not column.type?
        throw new Error 'Unrecognized type 0x' + column.type.toString 16
      column.isNullable = column.flags & 0x01 isnt 0
      column.isCaseSensitive = column.flags & 0x02 isnt 0
      column.isIdentity = column.flags & 0x10 isnt 0
      column.isWriteable = column.flags & 0x0C isnt 0
      if not column.type.length?
        if column.type.hasScaleWithoutLength
          column.length = column.scale = stream.readByte()
        else 
          switch column.type.lengthType
            when 'int32LE' then column.length = stream.readInt32LE()
            when 'uint16LE' then column.length = stream.readUInt16LE()
            else column.length = stream.readByte()
        if column.type.lengthSubstitute?
          column.type = TdsConstants.dataTypesByType[column.type.lengthSubstitute[column.length]]
          if not column.type? then throw new Error 'Unable to find length substitute ' + column.length
        if column.type.hasCollation
          column.collation = stream.readBytes 5
        else if column.type.hasScaleAndPrecision
          column.scale = stream.readByte()
          column.precision = stream.readByte()
      else
        column.length = column.type.length
      # tableName
      if column.type.hasTableName
        column.tableName = stream.readUcs2String stream.readUInt16LE()
      # colName
      column.name = stream.readUcs2String stream.readByte()
      
