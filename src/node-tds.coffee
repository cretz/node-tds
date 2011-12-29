{EventEmitter} = require './events'

{TdsClient} = require './tds-client'

class Connection extends EventEmitter

  constructor: (@_options) ->
    @_client = new TdsClient
      message: (message) ->
        if @_currentStatement? then @_currentStatement.handler.message? message
        else @handler.message? message
      connect: (connect) ->
        @_client.login @_options
      login: (login) ->
        cb = @_pendingLoginCallback
        @_pendingLoginCallback = null
        cb?()
      row: (row) ->
        @_currentStatement.row row
      colmetadata: (colmetadata) ->
        @_currentStatement.colmetadata colmetadata
      done: (done) ->
        @_currentStatement.done done

  
  connect: (cb) ->
    throw new Error 'Not yet implemented'

  createStatement: (sql, params, handler) ->
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
    @_client.end()

class Statement extends EventEmitter

  constructor: (@_connection, sql, @_params, @handler) ->
    # simple SQL escaping, caller is expected to be smarter
    @_sql = sql.replace "'", "''"
    if @_params?
      # build the parameter string
      parameterString = ''
      for key, value of @_params
        # simple sanity checks
        if typeof key isnt 'string' or typeof value.type isnt 'string'
          throw new Error 'Unexpected param name or type name'
        if value.size? and typeof value.size isnt 'number'
          throw new Error 'Unexpected type for value size'
        if value.scale? and typeof value.scale isnt 'number'
          throw new Error 'Unexpected type for value scale'
        if value.precision? and typeof value.precision isnt 'number'
          throw new Error 'Unexpected type for value precision'
        if key.indexOf ',' isnt -1 or value.indexOf ',' isnt -1
          throw new Error 'Cannot have comma in parameter list'
        if key.indexOf '@' isnt -1 or value.indexOf '@' isnt -1
          throw new Error 'Cannot have at sign (@) in parameter list'
        if key.indexOf ' ' isnt -1 or value.indexOf ' ' isnt -1
          throw new Error 'Cannot have space in parameter list'
        if key.indexOf "'" isnt -1 or value.indexOf "'" isnt -1
          throw new Error 'Cannot have apostrophe in parameter list'
        if parameterString isnt ''
          parameterString += ','
        # append
        parameterString += '@' + key + ' ' + value.type
        if value.size? then parameterString += '(' + value.size + ')'
        else if value.scale? and value.precision?
          parameterString += '(' + value.precision + ',' + value.scale + ')'
        if value.output then parameterString += ' OUTPUT'
      @_sql = "EXECUTE sp_executesql N'" + @_sql + "', N'" + parameterString + "'"

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
      paramSql = ''
      for key, value of paramValues
        param = @_params[key]
        if not param?
          throw new Error 'Undefined parameter ' + key
        if paramSql isnt '' then paramSql += ', '
        paramSql += '@' + key + ' = '
        switch typeof value
          when 'string'
            paramSql += "N'" + value.replace "'", "''"
          when 'number'
            paramSql += value
          when 'boolean'
            paramSql += if value then 1 else 0
          when 'null'
            paramSql += 'NULL'
          when 'object'
            # TODO - support buffers here
            if value instanceof Date
              paramSql += "'" + 
                @_formatDate(value, not param.timeOnly, not param.dateOnly) + "'"
            else
              throw new Error 'Unsupported parameter type: ' + typeof value
          else throw new Error 'Unsupported parameter type: ' + typeof value
      if paramSql isnt ''
        @_connection._client.sqlBatch @_sql + ', ' + paramSql
      else
        @_connection._client.sqlBatch @_sql

  # TODO - send attention, ignore extra data until we receive notification of cancel
  cancel: ->
    throw new Error 'Not yet implemented'

  colmetadata: (colmetadata) ->
    @columns = colmetadata.columns
    if @handler? then @handler.metadata? @columns
    else @emit 'metadata', @columns

  row: (row) ->
    if @handler? then @handler.row? row
    else @emit 'row', row

  done: (done) ->
    if @handler? then @handler.done? done
    else @emit 'done', done

  _formatDate: (date, includeDate, includeTime) ->
    str = ''
    if includeDate
      # datetime2 can start at 0001
      str += '0' if date.getFullYear() < 1000
      str += '0' if date.getFullYear() < 100
      str += '0' if date.getFullYear() < 10
      str += date.getFullYear() + '-'
      str += '0' if date.getMonth() < 10
      str += date.getMonth() + '-'
      str += '0' if date.getDate() < 10
      str += date.getDate()
    if includeTime
      str += ' ' if str isnt ''
      str += '0' if date.getHours() < 10
      str += date.getHours() + ':'
      str += '0' if date.getMinutes() < 10
      str += date.getMinutes() + ':'
      str += '0' if date.getSeconds() < 10
      str += date.getSeconds() + '.'
      str += '0' if date.getMilliseconds() < 100
      str += '0' if date.getMilliseconds() < 10
      str += date.getMilliseconds()


