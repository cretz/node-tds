{TestConstants} = require './constants.test'
{TestUtils} = require './utils.test'

describe 'Statement', ->
  
  describe '#execute', ->
    conn = null
    beforeEach ->
      conn = TestUtils.newConnection()
    
    afterEach ->
      conn?.end()

    it 'should return multiple result sets properly', (alldone) ->
      # What we're doing here is returning a bunch of individual row results
      #   off of a range of records...
      rowCount = 0
      doneCount = 0
      handler =
        row: ->
          rowCount++
          conn._client.debug 'GOT ROW!: ', rowCount
        done: ->
          if rowCount >= 1000 
            alldone()
      conn.connect =>
        # ask for 30000 results
        sql = """
              DECLARE @i INT
              SET @i = 0
              WHILE (@i < 1000)
              BEGIN
              SELECT @i = @i + 1
              SELECT 'Test'
              END
              """
        stmt = conn.createStatement sql, null, handler
        stmt.execute()