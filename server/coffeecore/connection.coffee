Player = require('./core/player.js')

class Connection
  
  # It should have these attributes if properly instantiated:
  # id      : null
  # ip      : null
  # socket  : null
  
  constructor : (params) ->
    @[k] = v for k,v of params # extend the prototype with constructor params
    @
  
  # public static methods  
  @playerJoin   : (data) ->
    # when they connect they should be added to a pool of connected user ids
    # more or less permanent store?
    
  
  @disconnect   : (data) ->
  @addLine      : (data) ->
  @sendMessage  : (data) ->
  @guessWord    : (data) ->


module.exports = Connection