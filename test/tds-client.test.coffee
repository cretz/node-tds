fs = require 'fs'
path = require 'path'
{ spawn, exec } = require 'child_process'

{TdsClient} = require '../lib/tds-client'

startSqlServer = (done) ->
  console.log 'Starting SQL server'
  proc = spawn 'net', ['start', 'SQL Server (SQLEXPRESS)']
  proc.stderr.on 'data', (buffer) -> console.log buffer.toString()
  proc.stdout.on 'data', (buffer) -> console.log buffer.toString()
  proc.on 'exit', (status) ->
   done()

describe 'TdsClient', ->
  
  before (done) ->
    startSqlServer done
  
  describe '#connect()', ->
    it 'should connect without errors', (done) ->
      console.log 'TODO: these tests'
      done()
