module.exports =

  objKeyCount : (o) ->
    i = 0
    i++ for k,v of o
    i
    
  extend : (target, extender) ->
      target = {} unless target?
      target[k] = v for k,v of extender
      target
      
  R : (l,h) -> Math.floor(
    l + (Math.random()*(h-l+1))
  )
  
  # Randomly choose an element from an array.
  AR : (a) -> a[ Math.floor(Math.random()*a.length) ]
  
  # Weighted object random. Selects a key from an obj based on the weight (value) of that key.
  WR : (o, sum=0) ->
    (sum += v) for k,v of o
    sum_ = 1/sum
    r = Math.random()
    (
      if !(intervalEnd?) then intervalEnd = v*sum_
      if r < intervalEnd
        return k
      else
        intervalEnd += v*sum_
        lastK = k
    ) for k, v of o
    k
    