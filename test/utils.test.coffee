assert = require 'assert'

{Connection} = require '../lib/tds'
{TestConstants} = require './constants.test'

class exports.TestUtils

  @newConnection: ->
    new Connection
      host: TestConstants.host
      port: TestConstants.port
      serverName: TestConstants.serverName
      userName: TestConstants.userName
      password: TestConstants.password
      logError: TestConstants.logError
      logDebug: TestConstants.logDebug
  
  @assertRow: (row, name, expected) ->
    actual = row.getValue name
    if Buffer.isBuffer expected
      util = require 'util'
      assert.deepEqual actual, expected,
        'For name ' + name + ', actual: ' + util.inspect(actual) + 
          ', expected buffer: ' + util.inspect(expected)
    else if expected instanceof Date
      assert.equal actual.getTime(), expected.getTime(),
        'For name ' + name + ', actual: ' + actual + 
          ', expected: ' + expected
    else
      # round floats
      if typeof actual is 'number' and actual % 1 isnt 0
        actual = Math.round(actual * 10) / 10
      assert.equal actual, expected,
        'For name ' + name + ', actual: ' + actual + 
          ', expected: ' + expected
    
