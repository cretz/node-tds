{TestConstants} = require './constants.test'
{TestUtils} = require './utils.test'

describe 'Connection', ->
  
  describe '#end', ->
    conn = null
    beforeEach ->
      conn = TestUtils.newConnection()
    
    afterEach ->
      conn?.end()

    it 'should trigger end properly', (alldone) ->
      conn.handler =
        close: =>
          alldone()
      conn.connect =>
        # wait for 1 minute then force error
        stmt = conn.createStatement "WAITFOR DELAY '00:10'", null, 
          done: -> alldone new Error('End not called!')
        stmt.execute()
      # lets kill it since I can't call KILL @@SPID
      conn._client._socket.destroy()