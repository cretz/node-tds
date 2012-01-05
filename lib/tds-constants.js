/**
Class with static TDS info
*/
exports.TdsConstants = (function() {
  var i, key, value, _len, _len2, _ref, _ref2, _ref3, _ref4;

  function TdsConstants() {}

  /**
  * Versions indexed by the TDS protocol version
  */

  TdsConstants.versionsByVersion = {
    '7.0': 0x70000000,
    '7.1': 0x71000000,
    '7.1.1': 0x71000001,
    '7.2': 0x72090002,
    '7.3.A': 0x730A0003,
    '7.3.B': 0x730B0003,
    '7.4': 0x74000004
  };

  /**
  * Versions indexed by the server-number in the spec
  */

  TdsConstants.versionsByNumber = {};

  _ref = TdsConstants.versionsByVersion;
  for (value = 0, _len = _ref.length; value < _len; value++) {
    key = _ref[value];
    TdsConstants.versionsByNumber[value] = key;
  }

  /**
  * States by their number
  */

  TdsConstants.statesByNumber = ['INITIAL', 'CONNECTING', 'CONNECTED', 'LOGGING IN', 'LOGGED IN'];

  TdsConstants.statesByName = {};

  _ref2 = TdsConstants.statesByNumber;
  for (value = 0, _len2 = _ref2.length; value < _len2; value++) {
    key = _ref2[value];
    TdsConstants.statesByName[key] = value;
  }

  /**
  * Data types, indexed by the type in the spec
  */

  TdsConstants.dataTypesByType = {
    0x1F: {
      name: 'NULLTYPE',
      sqlType: 'Null',
      length: 0
    },
    0x22: {
      name: 'IMAGETYPE',
      sqlType: 'Image',
      lengthType: 'int32LE',
      hasTableName: true,
      emptyPossible: true
    },
    0x23: {
      name: 'TEXTTYPE',
      sqlType: 'Text',
      lengthType: 'int32LE',
      hasCollation: true,
      hasTableName: true,
      emptyPossible: true
    },
    0x24: {
      name: 'GUIDTYPE',
      sqlType: 'UniqueIndentifier'
    },
    0x25: {
      name: 'VARBINARYTYPE',
      sqlType: 'VarBinary',
      lengthType: 'uint16LE',
      legacy: true,
      emptyPossible: true
    },
    0x26: {
      name: 'INTNTYPE',
      lengthSubstitutes: {
        0x01: 0x30,
        0x02: 0x34,
        0x04: 0x38,
        0x08: 0x7F
      }
    },
    0x27: {
      name: 'VARCHARTYPE',
      sqlType: 'VarChar',
      lengthType: 'uint16LE',
      legacy: true,
      emptyPossible: true
    },
    0x28: {
      name: 'DATENTYPE',
      sqlType: 'Date',
      length: 3
    },
    0x29: {
      name: 'TIMENTYPE',
      sqlType: 'Time',
      hasScaleWithoutLength: true
    },
    0x2A: {
      name: 'DATETIME2NTYPE',
      sqlType: 'DateTime2',
      hasScaleWithoutLength: true
    },
    0x2B: {
      name: 'DATETIMEOFFSETNTYPE',
      sqlType: 'DateTimeOffset',
      hasScaleWithoutLength: true
    },
    0x2D: {
      name: 'BINARYTYPE',
      sqlType: 'Binary',
      lengthType: 'uint16LE',
      legacy: true,
      emptyPossible: true
    },
    0x2F: {
      name: 'CHARTYPE',
      sqlType: 'Char',
      lengthType: 'uint16LE',
      legacy: true,
      emptyPossible: true
    },
    0x30: {
      name: 'INT1TYPE',
      sqlType: 'TinyInt',
      length: 1
    },
    0x32: {
      name: 'BITTYPE',
      sqlType: 'Bit',
      length: 1
    },
    0x34: {
      name: 'INT2TYPE',
      sqlType: 'SmallInt',
      length: 2
    },
    0x37: {
      name: 'DECIMALTYPE',
      sqlType: 'Decimal',
      legacy: true,
      hasScaleAndPrecision: true
    },
    0x38: {
      name: 'INT4TYPE',
      sqlType: 'Int',
      length: 4
    },
    0x3A: {
      name: 'DATETIM4TYPE',
      sqlType: 'SmallDateTime',
      length: 4
    },
    0x3B: {
      name: 'FLT4TYPE',
      sqlType: 'Real',
      length: 4
    },
    0x3C: {
      name: 'MONEYTYPE',
      sqlType: 'Money',
      length: 8
    },
    0x3D: {
      name: 'DATETIMETYPE',
      sqlType: 'DateTime',
      length: 8
    },
    0x3E: {
      name: 'FLT8TYPE',
      sqlType: 'Float',
      length: 8
    },
    0x3F: {
      name: 'NUMERICTYPE',
      sqlType: 'Numeric',
      legacy: true,
      hasScaleAndPrecision: true
    },
    0x62: {
      name: 'SSVARIANTTYPE',
      sqlType: 'Sql_Variant',
      lengthType: 'int32LE'
    },
    0x63: {
      name: 'NTEXTTYPE',
      sqlType: 'NText',
      lengthType: 'int32LE',
      hasCollation: true,
      hasTableName: true,
      emptyPossible: true
    },
    0x68: {
      name: 'BITNTYPE',
      lengthSubstitutes: {
        0x00: 0x1F,
        0x01: 0x32
      }
    },
    0x6A: {
      name: 'DECIMALNTYPE',
      sqlType: 'Decimal',
      hasScaleAndPrecision: true
    },
    0x6C: {
      name: 'NUMERICNTYPE',
      sqlType: 'Numeric',
      hasScaleAndPrecision: true
    },
    0x6D: {
      name: 'FLTNTYPE',
      lengthSubstitutes: {
        0x04: 0x3B,
        0x08: 0x3E
      }
    },
    0x6E: {
      name: 'MONEYNTYPE',
      lengthSubstitutes: {
        0x04: 0x7A,
        0x08: 0x3C
      }
    },
    0x6F: {
      name: 'DATETIMNTYPE',
      lengthSubstitutes: {
        0x04: 0x3A,
        0x08: 0x3D
      }
    },
    0x7A: {
      name: 'MONEY4TYPE',
      sqlType: 'SmallMoney',
      length: 4
    },
    0x7F: {
      name: 'INT8TYPE',
      sqlType: 'BigInt',
      length: 8
    },
    0xA5: {
      name: 'BIGVARBINTYPE',
      sqlType: 'VarBinary',
      lengthType: 'uint16LE',
      emptyPossible: true
    },
    0xA7: {
      name: 'BIGVARCHRTYPE',
      sqlType: 'VarChar',
      lengthType: 'uint16LE',
      emptyPossible: true,
      hasCollation: true
    },
    0xAD: {
      name: 'BIGBINARYTYPE',
      sqlType: 'Binary',
      lengthType: 'uint16LE',
      emptyPossible: true
    },
    0xAF: {
      name: 'BIGCHARTYPE',
      sqlType: 'Char',
      lengthType: 'uint16LE',
      hasCollation: true,
      emptyPossible: true
    },
    0xE7: {
      name: 'NVARCHARTYPE',
      sqlType: 'NVarChar',
      lengthType: 'uint16LE',
      hasCollation: true,
      emptyPossible: true
    },
    0xEF: {
      name: 'NCHARTYPE',
      sqlType: 'NChar',
      lengthType: 'uint16LE',
      hasCollation: true,
      emptyPossible: true
    },
    0xF0: {
      name: 'UDTTYPE',
      sqlType: 'CLR-UDT'
    },
    0xF1: {
      name: 'XMLTYPE',
      sqlType: 'XML'
    }
  };

  /**
  * Data types indexed be the name in the spec (all-caps)
  */

  TdsConstants.dataTypesByName = {};

  /**
  * Data types indexed by the sql type in the spec (regular and lowercase)
  */

  TdsConstants.dataTypesBySqlType = {};

  _ref3 = TdsConstants.dataTypesByType;
  for (key in _ref3) {
    value = _ref3[key];
    value.type = key;
    TdsConstants.dataTypesByName[value.name] = value;
    if ((value.lengthSubstitute != null) && !value.legacy) {
      TdsConstants.dataTypesBySqlType[value.sqlType] = value;
      TdsConstants.dataTypesBySqlType[value.sqlType.toLowerCase()] = value;
    }
  }

  /**
  * RPC special procedures array, by id in the spec
  */

  TdsConstants.specialStoredProceduresById = ['None', 'Sp_Cursor', 'Sp_CursorOpen', 'Sp_CursorPrepare', 'Sp_CursorExecute', 'Sp_CursorPrepExec', 'Sp_CursorUnprepare', 'Sp_CursorFetch', 'Sp_CursorOption', 'Sp_CursorClose', 'Sp_ExecuteSql', 'Sp_Prepare', 'Sp_Execute', 'Sp_PrepExec', 'Sp_PrepExecRpc', 'Sp_Unprepare'];

  /**
  * RPC special procedures by name (regular and lower cased) in the spec
  */

  TdsConstants.specialStoredProceduresByName = {};

  for (i = 0, _ref4 = TdsConstants.specialStoredProceduresById.length - 1; 0 <= _ref4 ? i <= _ref4 : i >= _ref4; 0 <= _ref4 ? i++ : i--) {
    TdsConstants.specialStoredProceduresByName[TdsConstants.specialStoredProceduresById[i]] = i;
    TdsConstants.specialStoredProceduresByName[TdsConstants.specialStoredProceduresById[i].toLowerCase()] = i;
  }

  TdsConstants.envChangeTypesByNumber = {
    1: {
      name: 'Database',
      oldValue: 'string',
      newValue: 'string'
    },
    2: {
      name: 'Language',
      oldValue: 'string',
      newValue: 'string'
    },
    3: {
      name: 'Character Set',
      oldValue: 'string',
      newValue: 'string'
    },
    4: {
      name: 'Packet Size',
      oldValue: 'string',
      newValue: 'string'
    },
    5: {
      name: 'Unicode data sorting local id',
      newValue: 'string'
    },
    6: {
      name: 'Unicode data sorting comparison flags',
      newValue: 'string'
    },
    7: {
      name: 'SQL Collation',
      oldValue: 'bytes',
      newValue: 'bytes'
    },
    8: {
      name: 'Begin Transaction',
      newValue: 'bytes'
    },
    9: {
      name: 'Commit Transaction',
      oldValue: 'bytes',
      newValue: 'byte'
    },
    10: {
      name: 'Rollback Transaction',
      oldValue: 'bytes'
    },
    11: {
      name: 'Enlist DTC Transaction',
      oldValue: 'bytes'
    },
    12: {
      name: 'Defect Transaction',
      newValue: 'bytes'
    },
    13: {
      name: 'Database Mirroring Partner',
      newValue: 'string'
    },
    15: {
      name: 'Promote Transaction',
      newValue: 'longbytes'
    },
    16: {
      name: 'Transaction Manager Address',
      newValue: 'bytes'
    },
    17: {
      name: 'Transaction Ended',
      oldValue: 'bytes'
    },
    18: {
      name: 'Reset Completion Acknowledgement'
    },
    19: {
      name: 'User Instance Name',
      newValue: 'string'
    },
    20: {
      name: 'Routing',
      oldValue: '2byteskip',
      newValue: 'shortbytes'
    }
  };

  return TdsConstants;

})();
