{TestConstants} = require './constants.test'
{TdsClient} = require '../lib/tds-client'

describe 'TdsClient', ->
  
  describe '#sqlBatch()', ->
    client = null

    afterEach ->
      client?.end()

    it 'should return 1 from SELECT 1', (done) ->
      receivedColMetaData = false
      client = new TdsClient
        error: (err) ->
          console.log 'Error: ', err.stack if TestConstants.logError
          done err
        connect: (packet) ->
          console.log 'Connected' if TestConstants.logDebug
          client.login
            userName: TestConstants.userName
            password: TestConstants.password
            serverName: TestConstants.serverName
        login: (packet) ->
          # SELECT 1
          client.sqlBatch 'SELECT 1'
        colmetadata: (packet) ->
          receivedColMetaData = true
        row: (packet) ->
          if not receivedColMetaData
            throw new Error 'No meta data'
          done()
      client.logError = TestConstants.logError
      client.logDebug = TestConstants.logDebug
      client.connect
        host: TestConstants.host
        port: TestConstants.port