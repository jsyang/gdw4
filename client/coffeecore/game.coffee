define [
  'core/playerCard'
  'core/predrawingArea'
  'core/drawingArea'
  'core/chat'
  'core/timer'
  'core/word'
], (PlayerCard, PredrawingArea, DrawingArea, Chat, Timer, Word) ->
    
  class DrawThisGame extends atom.Game
  
    # predrawingArea
    # drawingArea
    # chat
    # timer
    # playerCards
    # buttons
    
    user :
      cardsX : 0 # current position of the next player card
      timeElapsed : 0
      lastMouse : 
        x : 0
        y : 0
    
    isPointInsideUIThing : (point, thing) ->
      point.x >= thing.x          and
      point.x < thing.x + thing.w and
      point.y >= thing.y          and
      point.y < thing.y + thing.h
    
    findUIThing : (thing) ->
    
    clampMouseInsideDrawingArea : ->
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
      
      {
        x
        y
      }
    
      
    mode :
    
      current : 'predrawing'
      
      waitingforready : (dt) ->
      
      waitingforguess : (dt) ->
      
      predrawing : (dt) ->
        if (atom.input.released('touchfinger') or atom.input.released('mouseleft'))
        
          if @isPointInsideUIThing(atom.input.mouse, @predrawingArea.button.ok)
            if @predrawingArea.chosen.length is 2
              @drawingArea.chosen = @predrawingArea.chosen
              @mode.current = 'waitfordrawing'
              @drawingArea.draw()
            
          else if @isPointInsideUIThing(atom.input.mouse, @predrawingArea.button.reset)
            @predrawingArea.chosen = []
            w.chosen = false for w in @predrawingArea.words
            @predrawingArea.draw()
            
          
          else if @predrawingArea.chosen.length < 2
            (
              if @isPointInsideUIThing(atom.input.mouse, w)
                w.chosen = true
                @predrawingArea.chosen.push(w.value)
                break
            ) for w in @predrawingArea.words
            @predrawingArea.draw()
            atom.playSound('tick')
            
        return
      
      waitfordrawing : (dt) ->
        if (atom.input.down('touchfinger') or atom.input.down('mouseleft'))
          if @isPointInsideUIThing(atom.input.mouse, @drawingArea)
            @mode.current = 'drawing'
            @user.timeElapsed = 0
        @user.lastMouse =
          x : atom.input.mouse.x
          y : atom.input.mouse.y
          
      
      drawing : (dt) ->
        @user.timeElapsed += dt
        
        if (atom.input.released('touchfinger') or atom.input.released('mouseleft'))
          @mode.current = 'waitfordrawing'
          
          if @user.timeElapsed > 0.03 # no double click
            pen = @clampMouseInsideDrawingArea()
            @drawingArea.add({
              x1 : @user.lastMouse.x
              y1 : @user.lastMouse.y
              x2 : pen.x+0.5
              y2 : pen.y+0.5
            })
            @user.timeElapsed = 0
            @user.lastMouse = {
              x : pen.x
              y : pen.y
            }
          
          
        else
          pen = @clampMouseInsideDrawingArea()
          
          lastLine = @drawingArea[@drawingArea.length-1]
          if !(lastLine?) or 
            (lastLine? and
              lastLine.x1 != @user.lastMouse.x and
              lastLine.x2 != pen.x and
              lastLine.y1 != @user.lastMouse.y and
              lastLine.y2 != pen.y)
            
            @drawingArea.add({
              x1 : @user.lastMouse.x
              y1 : @user.lastMouse.y
              x2 : pen.x
              y2 : pen.y
            })
          
          @user.lastMouse = {
            x : pen.x
            y : pen.y
          }
      
    
    draw : ->
      @timer.draw()
      c.draw() for c in @playerCards
      return
    
    network:
      socket : null
      
      name : null
      role : null
      
      whoseTurn : 'SomeOtherPlayer' # hook this up so we all know whose turn it is
      
      sendName : ->
        sock = @network.socket
        
        @network.name = prompt('Your name', 'Player')
        @network.role = prompt('d for drawer, g for guesser', 'd')
        
        sock.emit('playerJoin', {
          playerName  : @network.name
          role        : @network.role
        })
        
        #sock.on('chat', (response) => @network.receiveChat.call(@, response) )
        
        switch @network.role
          when 'g'
            @mode.current = 'waitingforguess'
            sock.on('canvas', (response) => @network.receiveCanvas.call(@, response) )
          when 'd'
            @mode.current   = 'predrawing'
            @predrawingArea.draw()
          
      receiveCanvas : (response) ->
        @drawingArea.drawing = response.lines
        @drawingArea.draw()
      
      connectedToServer : false
      
    addPlayer : (player) ->
      @playerCards.push(
        new PlayerCard({
          name  : player.name
          x     : @user.cardsX
          game  : @
        })
      )
      @user.cardsX += PlayerCard.W + PlayerCard.MARGIN
      @playerCards
    
    removePlayer : (player) ->
      (
        if player.name is p.name
          found = p
          break
      ) for p in @playerCards
      
      if found?
        @user.cardsX -= PlayerCard.W + PlayerCard.MARGIN
        found.clear()
        @playerCards.splice(@playerCards.indexOf(found), 1)
        (
          p.clear()
          p.reorganize()
        ) for p in @playerCards
        
      @playerCards
    
    constructor : ->
      @registerInputs()
      @registerEvents()
      
      uiParams =
        game : @
      
      @predrawingArea = new PredrawingArea(uiParams)
      @drawingArea    = new DrawingArea(uiParams)
      @chat           = new Chat(uiParams)
      @timer          = new Timer(uiParams)
      @playerCards    = []
      @user.cardsX    += @drawingArea.x
      
      @addPlayer({ name : 'Jim' })
      
      # testing
      wlist = [
        'dog'
        'cat'
        'rat'
        'car'
        'hat'
        'bacon'
        'tasty'
        'nasty'
        'yummy'
        'long-winded'
        'tuesday'
      ]
      
      @predrawingArea.add(new Word({ value : w })) for w in wlist
      @predrawingArea.draw()
      
      @registerNetwork()
      return
    
    registerNetwork : ->
      @network.socket = io.connect('http://localhost:8000')
      #io.connect('http://ec2-54-215-79-196.us-west-1.compute.amazonaws.com:8080') # EC2 server
      
      @network.socket.on('welcome', =>
        @network.connectedToServer = true
        @network.sendName.apply(@)
      )
      return
    
    registerEvents : ->
      # Make sure user can see everything when the window is resized
      atom.resizeCb = =>
        @drawingArea.draw()
        @chat.resize().draw()
        @timer.resize().draw()
        return 
    
    registerInputs : ->
      atom.input.bind(atom.button.LEFT, 'mouseleft')
      atom.input.bind(atom.touch.TOUCHING, 'touchfinger')
    
    timeLeft : ->
      # todo : calculate the time left : difference in round start time (received from server) and round time limit
      79310 # $$.R(200, 79310)
    
    update : (dt) -> @mode[@mode.current].apply(@, [dt])