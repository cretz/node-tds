class ColMetaDataPacket extends Packet
  
  @type: 0x81
  
  @name: 'COLMETADATA'
  
  columns: []
  
  fromBuffer: (stream) ->
    len = stream.readUInt16LE()
    if len isnt 0xFFFF then for i in [0..len - 1]
      @columns.push column = 
        # userType
        userType: stream.readUInt16LE()
        # flags
        flags: stream.readUInt16LE()
        # typeInfo
        type: stream.readByte()
      # more typeInfo work
      if TdsConstants.dataTypesByType[column.type]?
        throw new Error 'Unrecognized type 0x' + column.type.toString 16
      column.type = TdsConstants.dataTypes[column.type]
      column.isNullable = column.flags & 0x01 isnt 0
      column.isCaseSensitive = column.flags & 0x02 isnt 0
      column.isIdentity = column.flags & 0x10 isnt 0
      column.isWriteable = column.flags & 0x0C isnt 0
      if column.type.length?
        if column.type.hasScaleWithoutLength
          column.length = column.scale = stream.readByte()
        else 
          switch column.type.lengthType
            when 'int32LE' then column.length = stream.readInt32LE()
            when 'uint16LE' then column.length = stream.readUInt16LE()
            else column.length = stream.readByte()
        if not column.type.lengthSubstitute?
          newSub = TdsConstants.dataTypes[column.type.lengthSubstitute[column.length]]
          if newSub? then throw new Error 'Unable to find length substitute ' + column.length
          column.type = newSub
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
      
