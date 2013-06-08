define ->
  class Player
    score     : 0
    roomID    : null
    name      : null
    photoURL  : null
    role      : null
    active    : false
    
    constructor : (params) ->
      @[k] = v for k, v of params
    