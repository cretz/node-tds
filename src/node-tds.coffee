{EventEmitter} = require 'events'

{TdsClient} = require './tds-client'
{TdsUtils} = require './tds-utils'

class exports.Connection extends EventEmitter

  constructor: (@_options) ->
    @_client = new TdsClient
      message: (message) =>
        # turn errors into actual errors
        if message.error
          err = new TdsError message.text, message
          if @_currentStatement? then @_currentStatement._error err
          else if @handler? then @handler.error? err
          else @emit 'error', err
        else if @_currentStatement? then @_currentStatement._message message
        else if @handler? then @handler.message? message
        else @emit 'message', message
      connect: (connect) =>
        @_client.login @_options
      login: (login) =>
        cb = @_pendingLoginCallback
        @_pendingLoginCallback = null
        cb?()
      row: (row) =>
        @_currentStatement._row row
      colmetadata: (colmetadata) =>
        @_currentStatement._colmetadata colmetadata
      done: (done) =>
        @_currentStatement?._done done
    @_client.logError = @_options?.logError
    @_client.logDebug = @_options?.logDebug
    @__defineGetter__ 'isExecutingStatement', ->
      @_currentStatement?
  
  connect: (@_pendingLoginCallback) ->
    @_client.connect @_options

  createStatement: (sql, params, handler) ->
    if @isExecutingStatement then throw new Error 'Statement currently running'
    if @_options.logDebug then console.log 'Creating statement: %s with params: ', sql, params
    new Statement @, sql, params, handler

  # TODO - build RPC call  
  createCall: (procName, params, handler) ->
    throw new Error 'Not yet implemented'

  # TODO - build bulk load (prebuilds colmetadata and done, does insert bulk call)
  # look at these two links for direction:
  #   http://sourceforge.net/projects/jbcp/
  #   https://github.com/mono/mono/blob/master/mcs/class/System.Data/System.Data.SqlClient/SqlBulkCopy.cs
  prepareBulkLoad: (tableName, batchSize, columns, cb) ->
    throw new Error 'Not yet implemented'

  # TODO - transactional stuff

  setAutoCommit: (@autoCommit, cb) ->
    throw new Error 'Not yet implemented'
  
  commit: (cb) ->
    throw new Error 'Not yet implemented'

  rollback: (cb) ->
    throw new Error 'Not yet implemented'

  end: ->
    @_currentStatement = null
    @_client.end()

Statement = class exports.Statement extends EventEmitter

  constructor: (@_connection, @_sql, @_params, @handler) ->
    if @_params?
      # build the parameter string
      parameterString = TdsUtils.buildParameterDefinition @_params
      if parameterString isnt ''
        @_sql = "EXECUTE sp_executesql N'" + @_sql.replace("'", "''") + "', N'" + parameterString + "'"

  # TODO - determine whether sp_prepare/sp_execute is obsolete nowadays
  # prepare: (cb) ->
  
  execute: (paramValues) ->
    @_connection._currentStatement = @
    # regular?
    if not @_params?
      @_connection._client.sqlBatch @_sql
    else
      # TODO - support batch
      # create actual params
      paramSql = TdsUtils.buildParameterSql @_params, paramValues
      if paramSql isnt ''
        @_connection._client.sqlBatch @_sql + ', ' + paramSql
      else
        @_connection._client.sqlBatch @_sql

  # TODO - send attention, ignore extra data until we receive notification of cancel
  cancel: ->
    throw new Error 'Not yet implemented'

  _error: (err) ->
    if @handler? then @handler.error? err
    else @emit 'error', err

  _message: (message) ->
    if @handler? then @handler.message? message
    else @emit 'message', message

  _colmetadata: (colmetadata) ->
    @metadata = colmetadata
    if @handler? then @handler.metadata? @metadata
    else @emit 'metadata', @metadata

  _row: (row) ->
    if @handler? then @handler.row? row
    else @emit 'row', row

  _done: (done) ->
    if not done.hasMore
      @_connection._currentStatement = null
    if @handler? then @handler.done? done
    else @emit 'done', done

TdsError = class exports.TdsError extends Error

  constructor: (@message, @info) ->
    @name = 'TdsError'
    @stack = (new Error).stack

