{TestConstants} = require './constants.test'
{TdsClient} = require '../lib/tds-client'

describe 'TdsClient', ->
    
  describe '#constructor()', ->
    it 'should throw an error without a handler', ->
      try 
        new TdsClient()
        throw new Error 'Error should have been thrown'
  
  describe '#connect()', ->
    client = null

    afterEach ->
      client?.end()

    it 'should connect without errors', (done) ->
      connected = false
      client = new TdsClient
        error: (err) ->
          console.error 'Error: ', err.stack if TestConstants.logError
          done err
        connect: (packet) ->
          console.log 'Connected' if TestConstants.logDebug
          done()
      client.logError = TestConstants.logError
      client.logDebug = TestConstants.logDebug
      client.connect
        host: TestConstants.host
        port: TestConstants.port
    
    it 'should return an error on invalid host/port', (done) ->
      client = new TdsClient
        error: (err) ->
          console.log 'Errored properly' if TestConstants.logDebug
          done()
        connect: (packet) ->
          console.log 'Connected' if TestConstants.logDebug
          done 'Connected'
      client.logError = TestConstants.logError
      client.logDebug = TestConstants.logDebug
      client.connect
        host: TestConstants.host
        port: TestConstants.port + 2
