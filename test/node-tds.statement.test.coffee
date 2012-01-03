assert = require 'assert'

{Connection} = require '../lib/node-tds'
{TestConstants} = require './constants.test'
{TestUtils} = require './utils.test'

describe 'Statement', ->
  
  describe '#execute', ->
    conn = null

    beforeEach ->
      conn = TestUtils.newConnection()

    afterEach ->
      conn?.end()

    metaDataUnreceived = true

    handler =
      message: (message) =>
        if TestConstants.logDebug then console.log 'Test message: ', message
      metadata: (metadata) =>
        metaDataUnreceived = false
        # check metadata
        for column in metadata.columns
          assert.equal column.name, column.type.sqlType + 'Type'
    
    sql = 
      '''
      SELECT CAST(@BitValue AS Bit) AS BitType,
             CAST(@TinyIntValue AS TinyInt) AS TinyIntType,
             CAST(@SmallIntValue AS SmallInt) AS SmallIntType,
             CAST(@IntValue AS Int) AS IntType,
             CAST(@BigIntValue AS BigInt) AS BigIntType,
             CAST(@CharValue AS Char(4)) AS CharType,
             CAST(@VarCharValue AS VarChar(7)) AS VarCharType,
             CAST(@NCharValue AS NChar(5)) AS NCharType,
             CAST(@NVarCharValue AS NVarChar(8)) AS NVarCharType,
             -- CAST(@BinaryValue AS Binary(1)) AS BinaryType,
             -- CAST(@VarBinaryValue AS VarBinary(1)) AS VarBinaryType,
             CAST(@RealValue AS Real) AS RealType,
             CAST(@FloatValue AS Float) AS FloatType,
             -- TODO CAST('stuffhere' AS UniqueIdentifier) AS UniqueIdentifierType,
             CAST(@SmallDateTimeValue AS SmallDateTime) AS SmallDateTimeType,
             CAST(@DateTimeValue AS DateTime) AS DateTimeType
             -- TODO CAST('2012-01-01' AS Date) AS DateType,
             -- TODO CAST(sometimehere AS Time) AS TimeType,
             -- TODO CAST('2012-01-01' AS DateTime2) AS DateTime2Type,
             -- TODO CAST(someoffsethere AS DateTimeOffset) AS DateTimeOffsetType
      '''

    params = {}
    params.BitValue = type: 'Bit'
    params.TinyIntValue = type: 'TinyInt'
    params.SmallIntValue = type: 'SmallInt'
    params.IntValue = type: 'Int'
    params.BigIntValue = type: 'BigInt'
    params.CharValue = type: 'Char', size: 4
    params.VarCharValue = type: 'VarChar', size: 7
    params.NCharValue = type: 'NChar', size: 5
    params.NVarCharValue = type: 'NVarChar', size: 8
    # TODO fix me
    # params.BinaryValue = type: 'Binary', size: 2
    # params.VarBinaryValue = type: 'VarBinary', size: 2
    params.RealValue = type: 'Real'
    params.FloatValue = type: 'Float'
    params.SmallDateTimeValue = type: 'SmallDateTime'
    params.DateTimeValue = type: 'DateTime'
    
    it 'should return nulls properly', (alldone) ->
      paramValues =
        BitValue: null
        TinyIntValue: null
        SmallIntValue: null
        IntValue: null
        BigIntValue: null
        CharValue: null
        VarCharValue: null
        NCharValue: null
        NVarCharValue: null
        # BinaryValue: null
        # VarBinaryValue: null
        RealValue: null
        FloatValue: null
        SmallDateTimeValue: null
        DateTimeValue: null

      handler.error = (error) =>
        if TestConstants.logError then console.error 'Test error: ', error.stack
        alldone error
      handler.row = (row) =>
        # check values
        checkNull = (name) ->
          actual = row.getValue name
          if actual? then throw new Error 'Column ' + name + ' was not null'
        checkNull 'BitType'
        checkNull 'TinyIntType'
        checkNull 'SmallIntType'
        checkNull 'IntType'
        checkNull 'BigIntType'
        checkNull 'CharType'
        checkNull 'VarCharType'
        checkNull 'NCharType'
        checkNull 'NVarCharType'
        # checkNull 'BinaryType'
        # checkNull 'VarBinaryType'
        checkNull 'RealType'
        checkNull 'FloatType'
        checkNull 'SmallDateTimeType'
        checkNull 'DateTimeType'

      handler.done = (done) =>
        if metaDataUnreceived then throw new Error 'No metadata retrieved'
        if not done.hasMore
          alldone()

      conn.handler = handler
      stmt = null
      conn.connect =>
        stmt = conn.createStatement sql, params, handler
        stmt.execute paramValues

    it 'should return proper data types and values', (alldone) ->
      paramValues =
        BitValue: 1
        TinyIntValue: 2
        SmallIntValue: 3
        IntValue: 4
        BigIntValue: 5
        CharValue: 'Char'
        VarCharValue: 'VarChar'
        NCharValue: 'NChar'
        NVarCharValue: 'NVarChar'
        # BinaryValue: new Buffer [0x06, 0x06]
        # VarBinaryValue: new Buffer [0x07, 0x07]
        RealValue: 8.1
        FloatValue: 9.1
        SmallDateTimeValue: new Date 2012, 0, 1
        DateTimeValue: new Date 2012, 0, 1

      handler.error = (error) =>
        if TestConstants.logError then console.error 'Test error: ', error.stack
        alldone error
      handler.row = (row) =>
        # check values
        TestUtils.assertRow row, 'BitType', paramValues.BitValue
        TestUtils.assertRow row, 'TinyIntType', paramValues.TinyIntValue
        TestUtils.assertRow row, 'SmallIntType', paramValues.SmallIntValue
        TestUtils.assertRow row, 'IntType', paramValues.IntValue
        TestUtils.assertRow row, 'BigIntType', paramValues.BigIntValue
        TestUtils.assertRow row, 'CharType', paramValues.CharValue
        TestUtils.assertRow row, 'VarCharType', paramValues.VarCharValue
        TestUtils.assertRow row, 'NCharType', paramValues.NCharValue
        TestUtils.assertRow row, 'NVarCharType', paramValues.NVarCharValue
        # TestUtils.assertRow row, 'BinaryType', paramValues.BinaryValue
        # TestUtils.assertRow row, 'VarBinaryType', paramValues.VarBinaryValue
        TestUtils.assertRow row, 'RealType', paramValues.RealValue
        TestUtils.assertRow row, 'FloatType', paramValues.FloatValue
        TestUtils.assertRow row, 'SmallDateTimeType', paramValues.SmallDateTimeValue
        TestUtils.assertRow row, 'DateTimeType', paramValues.DateTimeValue

      handler.done = (done) =>
        if metaDataUnreceived then throw new Error 'No metadata retrieved'
        if not done.hasMore
          alldone()
      conn.handler = handler
      stmt = null
      conn.connect =>
        stmt = conn.createStatement sql, params, handler
        stmt.execute paramValues