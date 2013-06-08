define ->
  class StatDisplay
    
    margin : 8
    
    constructor : (params) ->
      @[k] = v for k, v of params
    
    draw : ->
      # ac = atom.context
      return