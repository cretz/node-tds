{TestConstants} = require './constants.test'
{TestUtils} = require './utils.test'

describe 'Statement', ->
  
  describe '#cancel', ->
    conn = null
    beforeEach ->
      conn = TestUtils.newConnection()
    
    afterEach ->
      conn?.end()

    it 'should cancel properly', (alldone) ->
      handler = 
        error: (error) ->
          alldone error
        row: (row) ->
          throw new Error 'Should not have rows'
        done: (done) ->
          # TODO, figure out why this doesn't work
          # if done.isCancelled
          #  if TestConstants.logDebug then console.log 'Cancelled!'
          alldone()
      conn.connect =>
        # wait for 1 minute then force error
        stmt = conn.createStatement "WAITFOR DELAY '00:01:00'; SELECT CAST(-1 AS TinyInt);", null, handler
        stmt.execute()
        # cancel in a half second
        setTimeout stmt.cancel, 500