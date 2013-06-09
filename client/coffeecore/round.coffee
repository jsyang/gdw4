define ->
  class Round
    constructor : (params) ->
      @[k] = v for k, v of params
      if !@game? then throw 'game was not set!'
      
    chooseWordPile : ->
      