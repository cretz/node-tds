assert = require 'assert'

{Connection} = require '../lib/node-tds'
{TestConstants} = require './constants.test'

describe 'Statement', ->
  
  describe '#execute', ->
    conn = null

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
             -- TODO CAST(5 AS BigInt) AS BigIntType,
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
    afterEach ->
      conn?.end()

    it 'should return nulls properly', (alldone) ->
      paramValues =
        BitValue: null
        TinyIntValue: null
        SmallIntValue: null
        IntValue: null
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

      conn = new Connection
        host: TestConstants.host
        port: TestConstants.port
        serverName: TestConstants.serverName
        userName: TestConstants.userName
        password: TestConstants.password
        logError: TestConstants.logError
        logDebug: TestConstants.logDebug
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
        checkRow = (name, expected) ->
          actual = row.getValue name
          if Buffer.isBuffer expected
            util = require 'util'
            assert.deepEqual actual, expected,
              'For name ' + name + ', actual: ' + util.inspect(actual) + 
                ', expected buffer: ' + util.inspect(expected)
          else if expected instanceof Date
            assert.equal actual.getTime(), expected.getTime(),
              'For name ' + name + ', actual: ' + actual + 
                ', expected: ' + expected
          else
            # round floats
            if typeof actual is 'number' and actual % 1 isnt 0
              actual = Math.round(actual * 10) / 10
            assert.equal actual, expected,
              'For name ' + name + ', actual: ' + actual + 
                ', expected: ' + expected
        checkRow 'BitType', paramValues.BitValue
        checkRow 'TinyIntType', paramValues.TinyIntValue
        checkRow 'SmallIntType', paramValues.SmallIntValue
        checkRow 'IntType', paramValues.IntValue
        checkRow 'CharType', paramValues.CharValue
        checkRow 'VarCharType', paramValues.VarCharValue
        checkRow 'NCharType', paramValues.NCharValue
        checkRow 'NVarCharType', paramValues.NVarCharValue
        # checkRow 'BinaryType', paramValues.BinaryValue
        # checkRow 'VarBinaryType', paramValues.VarBinaryValue
        checkRow 'RealType', paramValues.RealValue
        checkRow 'FloatType', paramValues.FloatValue
        checkRow 'SmallDateTimeType', paramValues.SmallDateTimeValue
        checkRow 'DateTimeType', paramValues.DateTimeValue

      handler.done = (done) =>
        if metaDataUnreceived then throw new Error 'No metadata retrieved'
        if not done.hasMore
          alldone()

      conn = new Connection
        host: TestConstants.host
        port: TestConstants.port
        serverName: TestConstants.serverName
        userName: TestConstants.userName
        password: TestConstants.password
        logError: TestConstants.logError
        logDebug: TestConstants.logDebug
      conn.handler = handler
      stmt = null
      conn.connect =>
        stmt = conn.createStatement sql, params, handler
        stmt.execute paramValues