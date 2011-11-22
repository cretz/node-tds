class TdsConstants
  
  @dataTypes = 
    # please keep in order
    0x1F: 
      name: 'NULLTYPE'
      sqlType: 'Null'
      length: 0
    0x22:
      name: 'IMAGETYPE'
      sqlType: 'Image'
      lengthType: 'int32LE'
    0x23:
      name: 'TEXTTYPE'
      sqlType: 'Text'
      lengthType: 'int32LE'
    0x24:
      name: 'GUIDTYPE'
      sqlType: 'UniqueIndentifier'
    0x25:
      name: 'VARBINARYTYPE'
      sqlType: 'VarBinary'
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
    0x2F:
      name: 'CHARTYPE'
      sqlType: 'Char'
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
      hasPrecision: true
      hasScale: true
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
      hasPrecision: true
      hasScale: true
    0x62:
      name: 'SSVARIANTTYPE'
      sqlType: 'Sql_Variant'
      lengthType: 'int32LE'
    0x63:
      name: 'NTEXTTYPE'
      sqlType: 'NText'
      lengthType: 'int32LE'
    0x68:
      name: 'BITNTYPE'
      lengthSubstitutes:
        0x00: 0x1F
        0x01: 0x32
    0x6A:
      name: 'DECIMALNTYPE'
      sqlType: 'Decimal'
      hasPrecision: true
      hasScale: true
    0x6C:
      name: 'NUMERICNTYPE'
      sqlType: 'Numeric'
      hasPrecision: true
      hasScale: true
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
    0xAD:
      name: 'BIGBINARYTYPE'
      sqlType: 'Binary'
      lengthType: 'uint16LE'
    0xAF:
      name: 'BIGCHARTYPE'
      sqlType: 'Char'
      lengthType: 'uint16LE'
    0xE7:
      name: 'NVARCHARTYPE'
      sqlType: 'NVarChar'
      lengthType: 'uint16LE'
    0xEF:
      name: 'NCHARTYPE'
      sqlType: 'NChar'
      lengthType: 'uint16LE'
    0xF0:
      name: 'UDTTYPE'
      sqlType: 'CLR-UDT'
    0xF1:
      name: 'XMLTYPE'
      sqlType: 'XML'











