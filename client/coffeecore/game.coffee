define [
  'core/drawingArea'
  'core/guesser'
], (DrawingArea, Guesser) ->
    
  class DrawThisGame extends atom.Game
    entities    : []
    drawingArea : null
    round       : { wordpile : ['dog','car','truck','blue','red','yellow'] }
    players     : {}
    
    user :
      timeElapsed : 0
      lastMouse : 
        x : 0
        y : 0
    
    isInsideUIThing : (thing) ->
      atom.input.mouse.x >= thing.x and
      atom.input.mouse.x < thing.x + thing.w and
      atom.input.mouse.y >= thing.y and
      atom.input.mouse.y < thing.y + thing.h
    
    findUIThing : (thing) ->
      
    mode :
      current : 'waitfordrawing'
      
      waitfordrawing : (dt) ->
        if (atom.input.down('touchfinger') or atom.input.down('mouseleft'))
          if @isInsideUIThing(@drawingArea)
            @mode.current = 'drawing'
        @user.lastMouse =
          x : atom.input.mouse.x
          y : atom.input.mouse.y
      
      drawing : (dt) ->
        if (atom.input.released('touchfinger') or atom.input.released('mouseleft'))
          @mode.current = 'waitfordrawing'
        else
          [x, y] = [atom.input.mouse.x, atom.input.mouse.y]
          
          # Clamp the drawn lines within the drawing area
          if x > @drawingArea.x+@drawingArea.w
            x = @drawingArea.x+@drawingArea.w
          else if x < @drawingArea.x
            x = @drawingArea.x
          
          if y > @drawingArea.y+@drawingArea.h
            y = @drawingArea.y+@drawingArea.h
          else if y < @drawingArea.y
            y = @drawingArea.y
          
          lastLine = @drawingArea[@drawingArea.length-1]
          if !(lastLine?) or 
            (lastLine? and
              lastLine.x1 != @user.lastMouse.x and
              lastLine.x2 != x and
              lastLine.y1 != @user.lastMouse.y and
              lastLine.y2 != y)
            
            @drawingArea.drawing.push({
              x1 : @user.lastMouse.x
              y1 : @user.lastMouse.y
              x2 : x
              y2 : y
            })            
          
          @user.lastMouse = {
            x
            y
          }
        
      predrawing : (dt) ->
        @updateEntities()
    
    
    draw : ->
      atom.context.clear()
      #(if e.draw? then e.draw()) for e in @entities
      @drawingArea.draw()
      
      i = 0
      margin = 16
      (
        if v.draw?
          v.draw(margin+i*(Guesser.W+margin), 432) 
          i++
      ) for k,v of @players
      
      return
    
    constructor : ->
      @registerInputs()
      @drawingArea = new DrawingArea()
      @players.jim = new Guesser({ name : 'Jim' })
      @players.andrew = new Guesser({ name : 'Andrew' })
    
    registerInputs : ->
      atom.input.bind(atom.button.LEFT, 'mouseleft')
      atom.input.bind(atom.touch.TOUCHING, 'touchfinger')
    
    update : (dt) ->
      @mode[@mode.current].apply(@, [dt])