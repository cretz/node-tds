assert = require 'assert'

{TestConstants} = require './constants.test'
{TestUtils} = require './utils.test'

describe 'Statement', ->
  
  describe '#setAutoCommit', ->
    conn = null
    beforeEach ->
      conn = TestUtils.newConnection()
    
    afterEach ->
      conn?.end()

    it 'should automatically commit by default', (alldone) ->
      # 0 is create table, 1 insert, 2 select
      stage = 0
      foundRow = false
      sql = 'CREATE TABLE #Test (Val VarChar(10))'
      handler =
        error: (error) ->
          console.log 'Error: ', error.stack
          alldone error 
        row: (row) ->
          if stage isnt 2
            throw new Error 'Invalid stage'
          else if not foundRow
            assert.equal row.getValue(0), 'meh'
            foundRow = true
          else
            throw new Error 'Found 2 rows'
        done: (done) ->
          sql = null
          switch stage
            when 0
              sql = "INSERT INTO #Test VALUES ('meh')"
              stage = 1
            when 1
              sql = 'SELECT * FROM #Test'
              stage = 2
            else
              sql = null
              if not foundRow then throw new Error 'No row found'
              else alldone()
          if sql? then conn.createStatement(sql, null, handler).execute()
      conn.handler = handler
      conn.connect =>
        conn.createStatement(sql, null, handler).execute()

    it 'should rollback when called', (alldone) ->
      # 0 is create table, 1 insert, 2 rolled back select
      stage = 0
      sql = 'CREATE TABLE #Test (Val VarChar(10))'
      handler =
        error: (error) ->
          console.log 'Error: ', error.stack
          alldone error 
        row: (row) ->
          throw new Error 'Row should not be received at stage ' + stage
        done: (done) ->
          switch stage
            when 0
              stage = 1
              conn.setAutoCommit false, =>
                conn.createStatement("INSERT INTO #Test VALUES ('meh')",
                  null, handler).execute()
            when 1
              conn.rollback =>
                stage = 2
                conn.createStatement("SELECT * FROM #Test", null, handler).execute()
            when 2
              alldone()
      conn.handler = handler
      conn.connect =>
        conn.createStatement(sql, null, handler).execute()

    it 'should commit when called', (alldone) ->
      # 0 is create table, 1 insert, 2 committed select
      stage = 0
      foundRow = false
      sql = 'CREATE TABLE #Test (Val VarChar(10))'
      handler =
        error: (error) ->
          console.log 'Error: ', error.stack
          alldone error 
        row: (row) ->
          assert.equal row.getValue(0), 'meh'
          foundRow = true
        done: (done) ->
          switch stage
            when 0
              stage = 1
              conn.setAutoCommit false, =>
                conn.createStatement("INSERT INTO #Test VALUES ('meh')",
                  null, handler).execute()
            when 1
              conn.commit =>
                stage = 2
                conn.createStatement("SELECT * FROM #Test", null, handler).execute()
            when 2
              if foundRow then alldone()
              else throw new Error 'Did not find row'
      conn.handler = handler
      conn.connect =>
        conn.createStatement(sql, null, handler).execute()
