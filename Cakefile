fs = require 'fs'
path = require 'path'
util = require 'util'
{ spawn, exec } = require 'child_process'

run = (cmd, args, cb) ->
  proc = spawn cmd, args
  proc.stderr.pipe process.stderr, end: false
  proc.stdout.pipe process.stdout, end: false
  proc.on 'exit', (status) ->
   process.kill(1) if status != 0
   cb() if typeof cb is 'function'
    
compile = (includeTests, cb) ->
  console.log 'Compiling'
  args = ['node_modules/coffee-script/bin/coffee', '-b', '-o', 'lib/', '-c', 'src/']
  completed = -> 
    console.log 'Compiled successfully'
    cb() if typeof cb is 'function'
  run 'node', args, if not includeTests then completed else ->
    args = ['node_modules/coffee-script/bin/coffee', '-b', '-c', 'test/']
    run 'node', args, completed
    
task 'clean', 'clean lib folder', ->
  console.log 'Cleaning'
  if path.existsSync 'lib'
    for file in fs.readdirSync 'lib'
      fs.unlinkSync path.join('lib', file) 
    fs.rmdirSync 'lib'
  fs.mkdirSync 'lib', 511
    
task 'compile', 'compile JS', ->
  invoke 'clean'
  compile false

task 'test', 'test node-tds', ->
  invoke 'clean'
  compile false, ->
    run 'node', ['node_modules/mocha/bin/mocha', '-t', '100s', '-R', 'spec'], 
      -> 'Tests complete'
