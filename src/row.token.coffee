{Token} = require './token'

class exports.RowToken extends Token
  
  @type: 0xD1
  @name: 'ROW'
  
  constructor: ->
    @type = 0xD1
    @name = 'ROW'
    @handlerFunction = 'row'
  
  fromBuffer: (stream, context) ->
    @values = new Array(context.columns.length)
    index = -1
    for column in context.columns
      # TODO - I know this is all wrong
      @values[++index] = stream.readBuffer(column.length) 
