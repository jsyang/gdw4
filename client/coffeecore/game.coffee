define [
  'core/drawingArea'
  'core/guesser'
  'core/chat'
  'core/timer'
], (DrawingArea, Guesser, Chat, Timer) ->
    
  class DrawThisGame extends atom.Game
    entities    : []
    drawingArea : null
    round       : { wordpile : ['dog','car','truck','blue','red','yellow'] }
    players     : {}
    
    user :
      initialDraw : false
      timeElapsed : 0
      lastMouse : 
        x : 0
        y : 0
    
    isPointInsideUIThing : (point, thing) ->
      point.x >= thing.x and
      point.x < thing.x + thing.w and
      point.y >= thing.y and
      point.y < thing.y + thing.h
    
    findUIThing : (thing) ->
      
    mode :
      current : 'waitfordrawing'
      
      waitfordrawing : (dt) ->
        if @network.role is 'd'
          if (atom.input.down('touchfinger') or atom.input.down('mouseleft'))
            if @isPointInsideUIThing(atom.input.mouse, @drawingArea)
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
            
            @drawingArea.add({
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
      # Only update the relevant areas so we don't have to constantly redraw stuff.
      #atom.context.clear()
      #(if e.draw? then e.draw()) for e in @entities
      
      
      i = 0
      margin = 16
      (
        if v.draw?
          v.draw(margin+i*(Guesser.W+margin), 432) 
          i++
      ) for k,v of @players
      
      return
    
    network:
      socket : null
      
      name : null
      role : null
      
      sendName : ->
        sock = @network.socket
        
        @network.name = prompt('your name')
        @network.role = prompt('d for drawer, g for guesser')
        
        sock.emit('playerJoin', {
          playerName  : @network.name
          role        : @network.role
        })
        
        #sock.on('chat', (response) => @network.receiveChat.call(@, response) )
        
        switch @network.role
          when 'g'
            sock.on('canvas', (response) => @network.receiveCanvas.call(@, response) )
          
      receiveCanvas : (response) ->
        @drawingArea.drawing = response.lines
        @drawingArea.draw()
      
      connectedToServer : false
      
    
    constructor : ->
      @registerInputs()
      @registerEvents()
      
      uiParams =
        game : @
      
      @drawingArea  = new DrawingArea(uiParams)
      @chat         = new Chat(uiParams)
      @timer        = new Timer(uiParams)
      
      #@players.jim = new Guesser({ name : 'Jim' })
      #@players.andrew = new Guesser({ name : 'Andrew' })
      
      @network.socket = io.connect('http://localhost:8000')
      #io.connect('http://ec2-54-215-79-196.us-west-1.compute.amazonaws.com:8080')
      
      @network.socket.on('welcome', =>
        @network.connectedToServer = true
        @network.sendName.apply(@)
      )
    
    registerEvents : ->
      atom.resizeCb = =>
        @drawingArea.draw()
        @chat.resize().draw()
        return 
    
    registerInputs : ->
      atom.input.bind(atom.button.LEFT, 'mouseleft')
      atom.input.bind(atom.touch.TOUCHING, 'touchfinger')
    
    timeLeft : ->
      79310
    
    update : (dt) ->
      @mode[@mode.current].apply(@, [dt])