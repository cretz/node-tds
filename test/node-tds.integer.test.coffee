{TestConstants} = require './constants.test'
{TestUtils} = require './utils.test'

describe 'Statement', ->
  
  describe '#execute', ->
    conn = null
    beforeEach ->
      conn = TestUtils.newConnection()
    
    afterEach ->
      conn?.end()

    it 'should return negative values properly', (alldone) ->
      
      handler = 
        row: (row) ->
          TestUtils.assertRow row, 0, -1
          TestUtils.assertRow row, 1, -1
          TestUtils.assertRow row, 2, '-1'
        done: (done) ->
          if not done.hasMore then alldone()  
      conn.handler = handler
      sql = 
        '''
        SELECT CAST(-1 AS SmallInt) AS SmallIntType,
               CAST(-1 AS Int) AS IntType,
               CAST(-1 AS BigInt) AS BigIntType
        '''
      conn.connect =>
        stmt = conn.createStatement sql, null, handler
        stmt.execute()