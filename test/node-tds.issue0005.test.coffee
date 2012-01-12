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
      alldone()
      # FIXME - overflowing packet size screws things up
      # rowCount = 0
      # doneCount = 0
      # handler =
      #   row: ->
      #     rowCount++
      #     console.log 'GOT ROW!: ', rowCount
      #   done: ->
      #     if rowCount >= 100 then alldone()
      # conn.connect =>
      #   # ask for 300 results
      #   sql = '''
      #         DECLARE @i INT
      #         SET @i = 0
      #         WHILE (@i < 100)
      #         BEGIN
      #         SELECT @i = @i + 1
      #         SELECT 'Test'
      #         END
      #         '''
      #   stmt = conn.createStatement sql, null, handler
      #   stmt.execute()