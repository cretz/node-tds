class exports.TdsConstants
  
  ###*
  * Versions indexed by the TDS protocol version
  ###
  @versionsByVersion:
    # SQL Server 7.0 and later
    '7.0': 0x00000070
    # SQL Server 2000 and later
    '7.1': 0x00000071
    # SQL Server 2000 SP1 and later
    '7.1.1': 0x01000071
    # SQL Server 2005 and later
    '7.2': 0x02000972
    # SQL Server 2008 and later
    '7.3.A': 0x03000A73
    # SQL Server 2008 (again) and later
    '7.3.B': 0x03000B73
    # SQL Server 2012 and later
    '7.4': 0x04000074
    
  ###*
  * Versions indexed by the server-number in the spec
  ###
  @versionsByNumber: {}
  
  # init versions
  for key, value in @versionsByVersion
    @versionsByNumber[value] = key
  
  ###*
  * Packets indexed by the type in the spec
  ###
  @packetsByType: {}
  
  # init the packet references
  @packetsByType[ColMetaDataPacket.type] = ColMetaDataPacket
  @packetsByType[DonePacket.type] = DonePacket
  @packetsByType[ErrorMessagePacket.type] = ErrorMessagePacket
  @packetsByType[InfoMessagePacket.type] = InfoMessagePacket
  @packetsByType[Login7Packet.type] = Login7Packet
  @packetsByType[LoginAckPacket.type] = LoginAckPacket
  @packetsByType[PreLoginPacket.type] = PreLoginPacket
  @packetsByType[RowPacket.type] = RowPacket
  @packetsByType[SqlBatchPacket.type] = SqlBatchPacket
  
  ###*
  * Data types, indexed by the type in the spec
  ###
  @dataTypesByType:
    # please keep in order
    0x1F: 
      name: 'NULLTYPE'
      sqlType: 'Null'
      length: 0
    0x22:
      name: 'IMAGETYPE'
      sqlType: 'Image'
      lengthType: 'int32LE'
      hasTableName: true
    0x23:
      name: 'TEXTTYPE'
      sqlType: 'Text'
      lengthType: 'int32LE'
      hasCollation: true
      hasTableName: true
    0x24:
      name: 'GUIDTYPE'
      sqlType: 'UniqueIndentifier'
    0x25:
      name: 'VARBINARYTYPE'
      sqlType: 'VarBinary'
      legacy: true
    0x26:
      name: 'INTNTYPE'
      lengthSubstitutes: 
        0x01: 0x30
        0x02: 0x34
        0x04: 0x38
        0x08: 0x7F
    0x27:
      name: 'VARCHARTYPE'
      sqlType: 'VarChar'
      legacy: true
    0x28:
      name: 'DATENTYPE'
      sqlType: 'Date'
      length: 3
    0x29:
      name: 'TIMENTYPE'
      sqlType: 'Time'
      hasScaleWithoutLength: true
    0x2A:
      name: 'DATETIME2NTYPE'
      sqlType: 'DateTime2'
      hasScaleWithoutLength: true
    0x2B:
      name: 'DATETIMEOFFSETNTYPE'
      sqlType: 'DateTimeOffset'
      hasScaleWithoutLength: true
    0x2D:
      name: 'BINARYTYPE'
      sqlType: 'Binary'
      legacy: true
    0x2F:
      name: 'CHARTYPE'
      sqlType: 'Char'
      legacy: true
    0x30: 
      name: 'INT1TYPE'
      sqlType: 'TinyInt'
      length: 1
    0x32:
      name: 'BITTYPE'
      sqlType: 'Bit'
      length: 1
    0x34:
      name: 'INT2TYPE'
      sqlType: 'SmallInt'
      length: 2
    0x37:
      name: 'DECIMALTYPE'
      sqlType: 'Decimal'
      legacy: true
      hasScaleAndPrecision: true
    0x38:
      name: 'INT4TYPE'
      sqlType: 'Int'
      length: 4
    0x3A:
      name: 'DATETIM4TYPE'
      sqlType: 'SmallDateTime'
      length: 4
    0x3B:
      name: 'FLT4TYPE'
      sqlType: 'Real'
      length: 4
    0x3C:
      name: 'MONEYTYPE'
      sqlType: 'Money'
      length: 8
    0x3D:
      name: 'DATETIMETYPE'
      sqlType: 'DateTime'
      length: 8
    0x3E:
      name: 'FLT8TYPE'
      sqlType: 'Float'
      length: 8
    0x3F:
      name: 'NUMERICTYPE'
      sqlType: 'Numeric'
      legacy: true
      hasScaleAndPrecision: true
    0x62:
      name: 'SSVARIANTTYPE'
      sqlType: 'Sql_Variant'
      lengthType: 'int32LE'
    0x63:
      name: 'NTEXTTYPE'
      sqlType: 'NText'
      lengthType: 'int32LE'
      hasCollation: true
      hasTableName: true
    0x68:
      name: 'BITNTYPE'
      lengthSubstitutes:
        0x00: 0x1F
        0x01: 0x32
    0x6A:
      name: 'DECIMALNTYPE'
      sqlType: 'Decimal'
      hasScaleAndPrecision: true
    0x6C:
      name: 'NUMERICNTYPE'
      sqlType: 'Numeric'
      hasScaleAndPrecision: true
    0x6D:
      name: 'FLTNTYPE'
      lengthSubstitutes:
        0x04: 0x3B
        0x08: 0x3E
    0x6E:
      name: 'MONEYNTYPE'
      lengthSubstitutes:
        0x04: 0x7A
        0x08: 0x3C
    0x6F:
      name: 'DATETIMNTYPE'
      lengthSubstitutes:
        0x04: 0x3A
        0x08: 0x3D
    0x7A:
      name: 'MONEY4TYPE'
      sqlType: 'SmallMoney'
      length: 4
    0x7F:
      name: 'INT8TYPE'
      sqlType: 'BigInt'
      length: 8
    0xA5:
      name: 'BIGVARBINTYPE'
      sqlType: 'VarBinary'
      lengthType: 'uint16LE'
    0xA7:
      name: 'BIGVARCHRTYPE'
      sqlType: 'VarChar'
      lengthType: 'uint16LE'
      hasCollation: true
    0xAD:
      name: 'BIGBINARYTYPE'
      sqlType: 'Binary'
      lengthType: 'uint16LE'
    0xAF:
      name: 'BIGCHARTYPE'
      sqlType: 'Char'
      lengthType: 'uint16LE'
      hasCollation: true
    0xE7:
      name: 'NVARCHARTYPE'
      sqlType: 'NVarChar'
      lengthType: 'uint16LE'
      hasCollation: true
    0xEF:
      name: 'NCHARTYPE'
      sqlType: 'NChar'
      lengthType: 'uint16LE'
      hasCollation: true
    0xF0:
      name: 'UDTTYPE'
      sqlType: 'CLR-UDT'
    0xF1:
      name: 'XMLTYPE'
      sqlType: 'XML' 

  ###*
  * Data types indexed be the name in the spec (all-caps)
  ###
  @dataTypesByName = {}
  
  ###*
  * Data types indexed by the sql type in the spec (regular and lowercase)
  ###
  @dataTypesBySqlType = {}
  
  # init the data type references 
  for key, value of @dataTypesByType
    # go ahead and set the type to the key here
    value.type = key
    @dataTypesByName[value.name] = value
    if value.lengthSubstitute? and not value.legacy
      @dataTypesBySqlType[value.sqlType] = value
      @dataTypesBySqlType[value.sqlType.toLowerCase()] = value

  ###*
  * RPC special procedures array, by id in the spec
  ###
  @specialStoredProceduresById = [
    'None',
    'Sp_Cursor',
    'Sp_CursorOpen',
    'Sp_CursorPrepare',
    'Sp_CursorExecute',
    'Sp_CursorPrepExec',
    'Sp_CursorUnprepare',
    'Sp_CursorFetch',
    'Sp_CursorOption',
    'Sp_CursorClose',
    'Sp_ExecuteSql',
    'Sp_Prepare',
    'Sp_Execute',
    'Sp_PrepExec',
    'Sp_PrepExecRpc',
    'Sp_Unprepare'
  ]

  ###*
  * RPC special procedures by name (regular and lower cased) in the spec
  ###
  @specialStoredProceduresByName = {}
  
  # init special stored procs
  for i in [0..@specialStoredProcedures.length - 1]
    @specialStoredProceduresByName[@specialStoredProceduresById[i]] = i
    @specialStoredProceduresByName[@specialStoredProceduresById[i].toLowerCase()] = i



