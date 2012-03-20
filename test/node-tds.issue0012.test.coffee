{TestConstants} = require './constants.test'
{TestUtils} = require './utils.test'

describe 'Statement', ->
  
  describe '#execute', ->
    conn = null
    beforeEach ->
      conn = TestUtils.newConnection()
    
    afterEach ->
      conn?.end()

    it 'should handle varchar and nvarchar max properly', (alldone) ->
      foundRow = false
      handler = 
        error: (error) ->
          alldone error
        row: (row) ->
          TestUtils.assertRow row, 'VarCharCol', 'Foo'
          TestUtils.assertRow row, 'NVarCharCol', 'Bar'
          foundRow = true
        done: (done) ->
          if foundRow
            alldone()
          else
            alldone new Error('Did not find row')
      conn.connect =>
        # select a varchar and nvarchar max
        stmt = conn.createStatement "SELECT CAST('Foo' AS VARCHAR(MAX)) AS VarCharCol, CAST('Bar' AS NVARCHAR(MAX)) AS NVarCharCol", null, handler
        stmt.execute()