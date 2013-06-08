define [
  'core/util'
  'core/atom'
  'core/game'
], (_util, _atom, DrawThisGame) ->
  
  startGame = ->
    window.game = new DrawThisGame()
    window.game.run()
    
  loaded =
    gfx : false
    sfx : false
    
  isPreloadComplete = ->
    if loaded.gfx and loaded.sfx
      startGame()    
      true
    else
      false
    
  atom.preloadImages({
    pen : 'pen.png'
  }, ->
    loaded.gfx = true
    isPreloadComplete()
  )
  
  atom.preloadSounds({
    tick        : 'tick.mp3'
  }, ->
    loaded.sfx = true
    isPreloadComplete()
  )
  
  return