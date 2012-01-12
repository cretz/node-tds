{TestConstants} = require './constants.test'
{TestUtils} = require './utils.test'

describe 'Statement', ->
  
  describe '#execute', ->
    conn = null
    beforeEach ->
      conn = TestUtils.newConnection()
    
    afterEach ->
      conn?.end()

    it 'should orderby properly', (alldone) ->
      # 0 create table, 1 insert, 2 select w/ order by
      stage = 0
      foundRow = false
      handler = 
        error: (error) ->
          alldone error
        row: (row) ->
          if stage is 2
            foundRow = row.getValue(0) is 'test'
        done: (done) ->
          if stage is 0
            stage = 1
            stmt = conn.createStatement "INSERT INTO ##TempTable VALUES ('test')", null, handler
            stmt.execute()
          else if stage is 1
            stage = 2
            stmt = conn.createStatement 'SELECT * FROM ##TempTable ORDER BY Val', null, handler
            stmt.execute()
          else if foundRow
            alldone()
          else
            alldone new Error('Did not find row')
      conn.connect =>
        # wait for 1 minute then force error
        stmt = conn.createStatement 'CREATE TABLE ##TempTable (Val VARCHAR(20) NOT NULL)', null, handler
        stmt.execute()