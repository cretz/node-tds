{Token} = require './token'

class exports.RowToken extends Token
  
  @type: 0xD1
  @name: 'ROW'
  
  constructor: ->
  	@type = 0xD1
  	@name = 'ROW'
  
  fromBuffer: (stream, context) ->
    @values = new Array(context.columns.length)
    for column in context.columns
      # TODO - I know this is all wrong
      @values.push stream.readBuffer(column.length) 