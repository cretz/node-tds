assert = require 'assert'

{TestConstants} = require './constants.test'
{TestUtils} = require './utils.test'

describe 'Statement', ->
  
  describe '#prepare', ->
    conn = null
    beforeEach ->
      conn = TestUtils.newConnection()
    
    afterEach ->
      conn?.end()

    it 'should prepare and unprepare properly', (alldone) ->
      stmt = null
      handler = 
        error: (error) ->
          console.log 'Error: ', error.stack
          alldone error
        row: (row) ->
          assert.equal row.getValue(0), 1
        done: (done) ->
          stmt.unprepare (error) =>
            if error? then alldone error
            else alldone()
      conn.handler = handler
      params = Val: type: 'Int'
      conn.connect =>
        stmt = conn.createStatement 'SELECT @Val', params, handler
        stmt.prepare (error) =>
          if error? then alldone error
          else 
            paramValues = Val: 1
            stmt.execute paramValues