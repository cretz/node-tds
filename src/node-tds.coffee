{EventEmitter} = require './events'

{TdsClient} = require './tds-client'

class Connection extends EventEmitter

  constructor: (@_options) ->
  	@_client = new TdsClient
  
  connect: (cb) ->

  createStatement: (sql, params) ->

  prepareStatement: (sql, params) ->

class Statement extends EventEmitter

  constructor: (@_connection, @_sql, @_params) ->
  
  execute: (paramValues) ->
  	@_connection.currentStatement = @

class PreparedStatement extends Statement
  
  constructor: (@_connection, @_handle, @_sql, @_params) ->

  _prepare: ->
  
  execute: (paramValues) ->
  	@_connection.currentStatement = @
