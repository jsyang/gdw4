define [
  'core/stageTitle'
], (stageTitle) ->
    
  class DrawThisGame extends atom.Game
    
    entities : []
    
    mode :
      current : 'draw'
      
      # Move the mouse around and make things follow you
      draw : (dt) ->
        @updateEntities()
    
    
    draw : ->
      atom.context.clear()
      (if e.draw? then e.draw()) for e in @entities
      return
    
    updateEntities : ->
      
    
    constructor : ->
      @registerInputs()
      @
    
    registerInputs : ->
      atom.input.bind(atom.button.LEFT, 'mouseleft')
      atom.input.bind(atom.touch.TOUCHING, 'touchfinger')
    
    update : (dt) ->
      @mode[@mode.current].apply(@, [dt])