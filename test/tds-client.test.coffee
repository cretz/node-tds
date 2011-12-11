fs = require 'fs'
path = require 'path'
assert = require 'assert'
{ spawn, exec } = require 'child_process'

{TdsClient} = require '../lib/tds-client'

startSqlServer = (done) ->
  console.log 'Starting SQL server'
  proc = spawn 'net', ['start', 'SQL Server (SQLEXPRESS)']
  proc.stderr.on 'data', (buffer) -> process.stderr.write buffer
  proc.stdout.on 'data', (buffer) -> process.stdout.write buffer
  proc.on 'exit', (status) ->
   done()

describe 'TdsClient', ->
  
  #before (done) ->
  #  startSqlServer done
    
  describe '#constructor()', ->
    it 'should throw an error without a handler', ->
      try 
        new TdsClient()
        throw new Error 'Error should have been thrown'
  
  describe '#connect()', ->
    it 'should connect without errors', (done) ->
      succeeded = false    
      client = new TdsClient
        error: (err) ->
          console.log 'Error: ', err.stack
          done err
        connect: (packet) ->
          console.log 'Connected'
          done()
        end: ->
          throw new Error 'Never connected'
      client.logError = client.logDebug = true
      client.connect
        #TODO move this in a conf
        host: 'localhost'
        port: 1433
    
    it 'should return an error on invalid host/port'