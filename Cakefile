fs = require 'fs'
path = require 'path'
{ spawn, exec } = require 'child_process'

run = (cmd, args, cb) ->
  proc = spawn cmd, args
  proc.stderr.on 'data', (buffer) -> console.log buffer.toString()
  proc.stdout.on 'data', (buffer) -> console.log buffer.toString()
  proc.on 'exit', (status) ->
   process.exit(1) if status != 0
   cb() if typeof cb is 'function'
    
compile = (includeTests, cb) ->
  console.log 'Compiling'
  args = ['-b', '-o', 'lib/', '-c', 'src/']
  completed -> 
    console.log 'Compiled successfully'
    cb() if typeof cb is 'function'
  run 'coffee', args, if not includeTests then completed else ->
    args = ['b', '-c', 'test/']
    run 'coffee', args, completed
    
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
  compile true, ->
    run 'expresso', ['--include', 'lib/', 'test/*']
