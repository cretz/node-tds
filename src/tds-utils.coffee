class exports.TdsUtils
  
  @buildParameterDefinition: (params, shouldAssert) ->
   parameterString = ''
   for key, value of params
      if shouldAssert
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
    parameterString
    
  @buildParameterSql: (params, paramValues) ->
    paramSql = ''
    for key, value of paramValues
      param = params[key]
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
              TdsUtils.formatDate(value, not param.timeOnly, not param.dateOnly) + "'"
          else
            throw new Error 'Unsupported parameter type: ' + typeof value
        else throw new Error 'Unsupported parameter type: ' + typeof value
    paramSql

  @formatDate: (date, includeDate, includeTime) ->
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

  @bigIntBufferToString: (buffer) ->
    throw new Error 'Unimplemented'