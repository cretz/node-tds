{TestConstants} = require './constants.test'
{TestUtils} = require './utils.test'

describe 'Statement', ->
  
  describe '#execute', ->
    conn = null
    beforeEach ->
      conn = TestUtils.newConnection()
    
    afterEach ->
      conn?.end()

    it 'should handle text properly', (alldone) ->
      rowFound = false
      handler = 
        row: (row) ->
          rowFound = true
          TestUtils.assertRow row, 0, 'Hello'
          TestUtils.assertRow row, 1, ''
          TestUtils.assertRow row, 2, null
        done: (done) ->
          if rowFound then alldone()
          else alldone new Error('No row found')
      conn.handler = handler
      sql = 
        '''
        SELECT CAST('Hello' AS Text) AS TextType1,
               CAST('' AS Text) AS TextType2,
               CAST(NULL AS Text) AS TextType3
        '''
      conn.connect =>
        stmt = conn.createStatement sql, null, handler
        stmt.execute()

    it 'should handle ntext properly', (alldone) ->
      rowFound = false
      handler = 
        row: (row) ->
          rowFound = true
          TestUtils.assertRow row, 0, 'Hello'
          TestUtils.assertRow row, 1, ''
          TestUtils.assertRow row, 2, null
        done: (done) ->
          if rowFound then alldone()
          else alldone new Error('No row found')
      conn.handler = handler
      sql = 
        '''
        SELECT CAST('Hello' AS NText) AS NTextType1,
               CAST('' AS NText) AS NTextType2,
               CAST(NULL AS NText) AS NTextType3
        '''
      conn.connect =>
        stmt = conn.createStatement sql, null, handler
        stmt.execute()

    it 'should handle image properly', (alldone) ->
      rowFound = false
      handler = 
        row: (row) ->
          rowFound = true
          TestUtils.assertRow row, 0, new Buffer [0x01, 0x02, 0x03]
          TestUtils.assertRow row, 1, new Buffer 0
          TestUtils.assertRow row, 2, null
        done: (done) ->
          if rowFound then alldone()
          else alldone new Error('No row found')
      conn.handler = handler
      sql = 
        '''
        SELECT CAST(0x010203 AS Image) AS ImageType1,
               CAST('' AS Image) AS ImageType2,
               CAST(NULL AS Image) AS ImageType3
        '''
      conn.connect =>
        stmt = conn.createStatement sql, null, handler
        stmt.execute()