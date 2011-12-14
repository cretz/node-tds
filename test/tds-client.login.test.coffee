{TestConstants} = require './constants.test'
{TdsClient} = require '../lib/tds-client'

describe 'TdsClient', ->
  
  describe '#login()', ->
    client = null

    afterEach ->
      client?.end()

    it 'should login without error', (done) ->
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
          done()
      client.logError = TestConstants.logError
      client.logDebug = TestConstants.logDebug
      client.connect
        host: TestConstants.host
        port: TestConstants.port