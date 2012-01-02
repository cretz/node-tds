assert = require 'assert'

{Connection} = require '../lib/node-tds'
{TestConstants} = require './constants.test'

describe 'Statement', ->
  
  describe '#execute', ->
    conn = null

    metaDataUnreceived = true

    handler =
      error: (error) =>
        if TestConstants.logError then console.error 'Test error: ', error.stack
        alldone error
      message: (message) =>
        if TestConstants.logDebug then console.log 'Test message: ', message
      metadata: (metadata) =>
        metaDataUnreceived = false
        # check metadata
        for column in metadata.columns
          assert.equal column.name, column.type.sqlType + 'Type'
    
    sql = 
      '''
      SELECT CAST(1 AS Bit) AS BitType,
             CAST(2 AS TinyInt) AS TinyIntType,
             CAST(3 AS SmallInt) AS SmallIntType,
             CAST(4 AS Int) AS IntType,
             -- TODO CAST(5 AS BigInt) AS BigIntType,
             CAST('Char' AS Char(4)) AS CharType,
             CAST('VarChar' AS VarChar(7)) AS VarCharType,
             CAST('NChar' AS NChar(5)) AS NCharType,
             CAST('NVarChar' AS NVarChar(8)) AS NVarCharType,
             CAST(6 AS Binary(1)) AS BinaryType,
             CAST(7 AS VarBinary(1)) AS VarBinaryType,
             CAST(8.1 AS Real) AS RealType,
             CAST(9.1 AS Float) AS FloatType,
             -- TODO CAST('stuffhere' AS UniqueIdentifier) AS UniqueIdentifierType,
             CAST('2012-01-01' AS SmallDateTime) AS SmallDateTimeType,
             CAST('2012-01-01' AS DateTime) AS DateTimeType
             -- TODO CAST('2012-01-01' AS Date) AS DateType,
             -- TODO CAST(sometimehere AS Time) AS TimeType,
             -- TODO CAST('2012-01-01' AS DateTime2) AS DateTime2Type,
             -- TODO CAST(someoffsethere AS DateTimeOffset) AS DateTimeOffsetType
      '''

    params = 
      BitType: type: 'Bit'

    afterEach ->
      conn?.end()

    it 'should return proper data types and values', (alldone) ->
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
        checkRow 'BitType', 1
        checkRow 'TinyIntType', 2
        checkRow 'SmallIntType', 3
        checkRow 'IntType', 4
        checkRow 'CharType', 'Char'
        checkRow 'VarCharType', 'VarChar'
        checkRow 'NCharType', 'NChar'
        checkRow 'NVarCharType', 'NVarChar'
        checkRow 'BinaryType', new Buffer [0x06]
        checkRow 'VarBinaryType', new Buffer [0x07]
        checkRow 'RealType', 8.1
        checkRow 'FloatType', 9.1
        checkRow 'SmallDateTimeType', new Date 2012, 0, 1
        checkRow 'DateTimeType', new Date 2012, 0, 1
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
        console.log 'Connection: ', conn
        stmt = conn.createStatement sql, null, handler
        stmt.execute()

