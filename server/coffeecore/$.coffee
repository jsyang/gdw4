module.exports =

  objKeyCount : (o) ->
    i = 0
    i++ for k,v of o
    i
    
  extend : (target, extender) ->
      target = {} unless target?
      target[k] = v for k,v of extender
      target