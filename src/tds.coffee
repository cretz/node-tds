{EventEmitter} = require 'events'

{TdsClient} = require './tds-client'
{TdsUtils} = require './tds-utils'

###*
Connection class for connecting to SQL Server
###
class exports.Connection extends EventEmitter

  constructor: (@_options) ->
    @_autoCommit = true
    @_client = new TdsClient
      error: (err) =>
        if @_pendingCallback?
          @_currentStatement = null
          cb = @_pendingCallback
          @_pendingCallback = null
          cb err
        else if @_pendingLoginCallback?
          cb = @_pendingLoginCallback
          @_pendingLoginCallback = null
          cb err
        else if @_currentStatement? then @_currentStatement._error err
        else if @handler? then @handler.error? err
        else @emit 'error', err
      message: (message) =>
        # turn errors into actual errors
        if message.error
          err = new TdsError message.text, message
          if @_pendingCallback?
            @_currentStatement = null
            cb = @_pendingCallback
            @_pendingCallback = null
            cb err
          else if @_pendingLoginCallback?
            cb = @_pendingLoginCallback
            @_pendingLoginCallback = null
            cb err
          else if @_currentStatement? then @_currentStatement._error err
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
        @_currentStatement?._row row
      colmetadata: (colmetadata) =>
        @_currentStatement?._colmetadata colmetadata
      done: (done) =>
        if done.hasMore then return
        if @_pendingCallback?
          if @_currentStatement is '#setAutoCommit' then @_autoCommit = not @_autoCommit
          @_currentStatement = null
          cb = @_pendingCallback
          @_pendingCallback = null
          cb()
        else if @_currentStatement? then @_currentStatement._done done
    @_client.logError = @_options?.logError
    @_client.logDebug = @_options?.logDebug
  
  connect: (@_pendingLoginCallback) =>
    @_client.connect @_options

  createStatement: (sql, params, handler) =>
    if @_currentStatement then throw new Error 'Statement currently running'
    if @_options.logDebug then console.log 'Creating statement: %s with params: ', sql, params
    new Statement @, sql, params, handler

  # TODO - build RPC call  
  createCall: (procName, params, handler) =>
    throw new Error 'Not yet implemented'

  # TODO - build bulk load (prebuilds colmetadata and done, does insert bulk call)
  # look at these two links for direction:
  #   http://sourceforge.net/projects/jbcp/
  #   https://github.com/mono/mono/blob/master/mcs/class/System.Data/System.Data.SqlClient/SqlBulkCopy.cs
  prepareBulkLoad: (tableName, batchSize, columns, cb) =>
    throw new Error 'Not yet implemented'

  setAutoCommit: (autoCommit, autoCommitCallback) =>
    # ignore if not changing anything
    if @_autoCommit is autoCommit
      cb()
    else
      if @_currentStatement?
        throw new Error 'Cannot change auto commit while statement is executing'
      @_pendingCallback = autoCommitCallback
      @_currentStatement = '#setAutoCommit'
      if autoCommit
        @_client.sqlBatch 'SET IMPLICIT_TRANSACTIONS OFF'
      else
        @_client.sqlBatch 'SET IMPLICIT_TRANSACTIONS ON'
  
  commit: (commitCallback) =>
    if @_autoCommit
      throw new Error 'Auto commit is on'
    if @_currentStatement?
      throw new Error 'Cannot commit while statement is executing'
    @_pendingCallback = commitCallback
    @_currentStatement = '#commit'
    @_client.sqlBatch 'IF @@TRANCOUNT > 0 COMMIT TRANSACTION'

  rollback: (rollbackCallback) =>
    if @_autoCommit
      throw new Error 'Auto commit is on'
    if @_currentStatement?
      throw new Error 'Cannot rollback while statement is executing'
    @_pendingCallback = rollbackCallback
    @_currentStatement = '#rollback'
    @_client.sqlBatch 'IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION'

  end: =>
    @_autoCommit = true
    @_pendingCallback = null
    @_currentStatement = null
    @_client.end()

###*
Statement class
###
Statement = class exports.Statement extends EventEmitter

  constructor: (@_connection, @_sql, @_params, @handler) ->
    if @_params?
      # build the parameter string
      @_parameterString = TdsUtils.buildParameterDefinition @_params

  prepare: (cb) ->
    if @_preparedHandle?
      throw new Error 'Statement already prepared'
    if not @_parameterString? or @_parameterString is ''
      # just tossing this here for best practices
      throw new Error 'Cannot prepare statement without parameters'
    if @_connection._currentStatement?
      throw new Error 'Another statement already executing'
    @_connection._currentStatement = @
    sql = "DECLARE @hndl Int;\nEXECUTE sp_prepare @hndl OUTPUT, N'" +
      @_parameterString + "',\nN'" + @_sql.replace(/'/g, "''") + 
      "\n', 1;\nSELECT @hndl;"
    @_pendingPrepareCallback = cb
    @_connection._client.sqlBatch sql

  unprepare: (cb) ->
    if not @_preparedHandle?
      throw new Error 'Statement not prepared'
    if @_connection._currentStatement?
      throw new Error 'Another statement already executing'
    @_connection._currentStatement = @
    @_pendingUnprepareCallback = cb
    @_connection._client.sqlBatch 'sp_unprepare ' + @_preparedHandle
  
  execute: (paramValues) =>
    if @_connection._currentStatement?
      throw new Error 'Another statement already executing'
    @_connection._currentStatement = @
    sql = null
    # regular?
    if not @_params? or @_parameterString is ''
      sql = @_sql
    else if @_preparedHandle?
      sql = 'EXECUTE sp_execute ' + @_preparedHandle + ', ' +
        TdsUtils.buildParameterizedSql @_params, paramValues
    else
      if not @_parameterizedSql?
        @_parameterizedSql = "EXECUTE sp_executesql \nN'" + 
          @_sql.replace(/'/g, "''") + "\n', N'" + @_parameterString + "'"
      sql = @_parameterizedSql + ', ' +
        TdsUtils.buildParameterizedSql @_params, paramValues
    @_connection._client.sqlBatch sql

  # TODO - send attention, ignore extra data until we receive notification of cancel
  cancel: =>
    if @_pendingPrepareCallback? or @_pendingUnprepareCallback?
      throw new Error 'Unable to cancel (un)prepare'
    @_cancelling = true
    @_connection._client.cancel()

  _error: (err) =>
    if @_pendingPrepareCallback?
      cb = @_pendingPrepareCallback
      @_pendingPrepareCallback = null
      @_connection.currentStatement = null
      cb err
      @_ignoreNextDone = true
    else if @_pendingUnprepareCallback?
      cb = @_pendingUnprepareCallback
      @_pendingUnprepareCallback = null
      @_connection.currentStatement = null
      cb err
      @_ignoreNextDone = true
    else if @handler? then @handler.error? err
    else @emit 'error', err

  _message: (message) =>
    if @handler? then @handler.message? message
    else @emit 'message', message

  _colmetadata: (colmetadata) =>
    if not @_cancelling and not @_pendingPrepareCallback? and not @_pendingUnprepareCallback?
      @metadata = colmetadata
      if @handler? then @handler.metadata? @metadata
      else @emit 'metadata', @metadata

  _row: (row) =>
    if @_pendingPrepareCallback?
      @_preparedHandle = row.getValue 0
    else if not @_cancelling
      if @handler? then @handler.row? row
      else @emit 'row', row

  _done: (done) =>
    if @_ignoreNextDone
      @_ignoreNextDone = undefined
    else if @_pendingPrepareCallback?
      cb = @_pendingPrepareCallback
      @_pendingPrepareCallback = null
      @_connection._currentStatement = null
      cb()
    else if @_pendingUnprepareCallback?
      cb = @_pendingUnprepareCallback
      @_pendingUnprepareCallback = null
      @_preparedHandle = undefined
      @_connection._currentStatement = null
      cb()
    else 
      if @_cancelling
        # TODO figure out why status doesn't show cancel
        @_cancelling = undefined
      @_connection._currentStatement = null
      if @handler? then @handler.done? done
      else @emit 'done', done

###*
TdsError class
###
TdsError = class exports.TdsError extends Error

  constructor: (@message, @info) ->
    @name = 'TdsError'
    @stack = (new Error).stack

