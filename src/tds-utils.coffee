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
    
  @buildParameterizedSql: (params, paramValues) ->
    paramSql = ''
    for key, value of paramValues
      param = params[key]
      if not param?
        throw new Error 'Undefined parameter ' + key
      if paramSql isnt '' then paramSql += ', '
      paramSql += '@' + key + ' = '
      switch typeof value
        when 'string'
          # bigints are special
          if param.type.toUpperCase() is 'BIGINT'
            # no need to sanity check, SQL server should break; trusting caller
            paramSql += value
          else paramSql += "N'" + value.replace(/'/g, "''") + "'"
        when 'number'
          paramSql += value
        when 'boolean'
          paramSql += if value then 1 else 0
        when 'object'
          if not value?
            paramSql += 'NULL'
          else if value instanceof Date
            paramSql += "'" +
              TdsUtils.formatDate(value, not param.timeOnly, not param.dateOnly) + "'"
          else if Buffer.isBuffer value
            paramSql += '0x' + value.toString 'hex'
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
      str += '0' if date.getMonth() < 9
      str += (date.getMonth() + 1) + '-'
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
    # TODO: optimize to 8 bytes
    # thanks to https://github.com/pekim/tedious/pull/2
    arr = Array.prototype.slice.call buffer, 0, buffer.length
    isZero = (array) ->
      for byte in array
        if byte != 0 then return false
      true
    if isZero arr then return '0'
    nextRemainder = (array) ->
      remainder = 0
      for index in [array.length - 1..0] by -1
        s = (remainder * 256) + array[index]
        array[index] = Math.floor s / 10
        remainder = s % 10
      remainder
    invert = (array) ->
      for byte, index in array
        array[index] = array[index] ^ 0xFF
      for byte, index in array
        array[index] = array[index] + 1
        if array[index] > 255 then array[index] = 0
        else break
    if arr[arr.length - 1] & 0x80
      sign = '-'
      invert arr
    else sign = ''
    result = ''
    until isZero arr
      t = nextRemainder arr
      result = t + result
    sign + result