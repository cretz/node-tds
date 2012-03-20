{TestConstants} = require './constants.test'
{TestUtils} = require './utils.test'

describe 'Statement', ->
  
  describe '#execute', ->
    conn = null
    beforeEach ->
      conn = TestUtils.newConnection()
    
    afterEach ->
      conn?.end()

    it 'should handle identities properly', (alldone) ->
      # 0 create table, 1 insert, 2 select
      stage = 0
      foundRow = false
      handler = 
        error: (error) ->
          alldone error
        row: (row) ->
          if stage is 2
            TestUtils.assertRow row, 'Id', '1'
            TestUtils.assertRow row, 'Val', 'test'
            foundRow = true
        done: (done) ->
          if stage is 0
            stage = 1
            stmt = conn.createStatement "INSERT INTO ##TempTable VALUES ('test')", null, handler
            stmt.execute()
          else if stage is 1
            stage = 2
            stmt = conn.createStatement 'SELECT * FROM ##TempTable', null, handler
            stmt.execute()
          else if foundRow
            alldone()
          else
            alldone new Error('Did not find row')
      conn.connect =>
        sql = """
              CREATE TABLE ##TempTable (
                Id BIGINT NOT NULL IDENTITY (1, 1),
                Val VARCHAR(20) NOT NULL
              )
              """
        stmt = conn.createStatement sql, null, handler
        stmt.execute()