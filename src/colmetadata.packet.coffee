class ColMetaDataPacket extends Packet
  
  type: 0x81
  
  name: 'COLMETADATA'
  
  columns: []
  
  fromBuffer: (stream, config) ->
    len = stream.readUInt16LE()
    for i in [0..len - 1]
      @columns.push column = 
        userType: stream.readUInt16LE()
        flags: stream.readUInt16LE()
        type: stream.readByte()
      if TdsConstants.dataTypes[column.type]?
        throw new Error 'Unrecognized type 0x' + column.type.toString 16
      column.type = TdsConstants.dataTypes[column.type]
      column.isNullable = column.flags & 0x01 isnt 0
      column.isCaseSensitive = column.flags & 0x02 isnt 0
      column.isIdentity = column.flags & 0x10 isnt 0
      column.isWriteable = column.flags & 0x0C isnt 0
      
        
      
