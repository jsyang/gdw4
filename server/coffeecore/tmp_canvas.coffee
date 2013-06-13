class Canvas # temporary only! we can push this off to something like redis or whatever
  
  lines         : []
  lastLineCount : 0
  
  constructor : (params) ->
    @[k] = v for k,v of params # extend the prototype with constructor params
    @

  addLine : (data) ->
    
module.exports = new Canvas()