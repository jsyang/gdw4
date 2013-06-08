define [
  'core/drawingArea'
], (DrawingArea) ->
    
  class DrawThisGame extends atom.Game
    entities    : []
    drawingArea : null
    
    user :
      lastMouse : 
        x : 0
        y : 0
    
    findUIThing
    
    mode :
      current : 'waitfordrawing'
      
      waitfordrawing : (dt) ->
        if (atom.input.down('touchfinger') or atom.input.down('mouseleft'))
          if @findUIThing(@drawingArea)
            @mode.current = 'drawing'
        @user.lastMouse =
          x : atom.input.mouse.x
          y : atom.input.mouse.y
      
      drawing : (dt) ->
        if (atom.input.up('touchfinger') or atom.input.up('mouseleft'))
            @mode.current = 'drawing'
        @user.lastMouse =
          x : atom.input.mouse.x
          y : atom.input.mouse.y
        
      predrawing : (dt) ->
        @updateEntities()
    
    
    draw : ->
      atom.context.clear()
      #(if e.draw? then e.draw()) for e in @entities
      @drawingArea.draw()
      return
    
    constructor : ->
      @registerInputs()
      @drawingArea = new DrawingArea()
    
    registerInputs : ->
      atom.input.bind(atom.button.LEFT, 'mouseleft')
      atom.input.bind(atom.touch.TOUCHING, 'touchfinger')
    
    update : (dt) ->
      @mode[@mode.current].apply(@, [dt])