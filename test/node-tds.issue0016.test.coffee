{TestConstants} = require './constants.test'
{TestUtils} = require './utils.test'

describe 'Statement', ->
  
  describe '#execute', ->
    conn = null
    beforeEach ->
      conn = TestUtils.newConnection()
    
    afterEach ->
      conn?.end()

    it 'should return numeric values properly', (alldone) ->
      
      handler = 
        row: (row) ->
          try
            TestUtils.assertRow row, 0, -100
            TestUtils.assertRow row, 1, 100
            TestUtils.assertRow row, 2, -5.5
            TestUtils.assertRow row, 3, 5.5
          catch err
            conn._client.debug 'Error: ', err, err.stack
        done: (done) ->
          alldone()  
      conn.handler = handler
      sql = 
        '''
        SELECT CAST(-100 AS Numeric(8, 3)) AS Numeric1,
               CAST(100 AS Numeric(8, 3)) AS Numeric2,
               CAST(-5.5 AS Numeric(8, 3)) AS Numeric3,
               CAST(5.5 AS Numeric(8, 3)) AS Numeric4
        '''
      conn.connect =>
        stmt = conn.createStatement sql, null, handler
        stmt.execute()