define ->
  class Network
    # Default required properties
    connected : false
    game      : null
    socket    : null
    
    id        : null
    name      : null
    role      : null
    room      : 'lobby'
    
    whoseTurn : null
  
    constructor : (params) ->
      @[k] = v for k,v of params
      throw 'game was not set!'   unless @game?
      throw 'socket was not set!' unless @socket?
      @registerClientEvents()
      @send_hello()
    
    registerClientEvents : ->
      @socket.on('welcome',       (d)=> @receive_welcome(d))              # x
      @socket.on('playerlist',    (d)=> @receive_playerlist(d))           # x
      @socket.on('playeradd',     (d)=> @receive_playeradd(d))            # 
      @socket.on('playerremove',  (d)=> @receive_playerremove(d))         #
      @socket.on('canvaspage',    (d)=> @receive_canvaspage(d))           # x
      @socket.on('canvasline',    (d)=> @receive_canvasline(d))           # x
      @socket.on('chatlog',       (d)=> @receive_chatlog(d))              # x
      @socket.on('chatmsg',       (d)=> @receive_chatmsg(d))              # x
      @socket.on('words',         (d)=> @receive_words(d))                # x
      @socket.on('drawwords',     (d)=> @receive_draw_candidate_words(d)) # 
      return
    
    # TX (Transmission Send) Events # # # # # # # #
    
    send_hello : ->
      @name = prompt('Your name', "guest#{$$.R(1000,9999)}")
      @socket.emit('hello', { name : @name })
    
    send_joinroom : ->
      # Keep room and name if resuming a session
      @room = prompt('Room', 'lobby')       #unless @room?
      
      @socket.emit('joinroom', {
        room  : @room
        name  : @name
      })

      @game.mode.init.call(@game)
      return
      
    send_chatmsg : (msg) ->
      @socket.emit('chatmsg', {
        name  : @name
        msg   : msg
      })
      return
      
    send_canvasline : (line) ->
      @socket.emit('canvasline', line)
      return
      
    # TR (Transmission Receive) Events # # # # # # # #
      
    receive_welcome : (data) ->
      @id         = data?.id
      @role       = data?.role
      
      @connected  = true
      @send_joinroom()
    
    receive_playerlist : (data) ->
      @game.addPlayer({ name }) for name in data
    
    receive_chatlog : (data) ->
      if data?
        @game.chat.messages = data
        @game.chat.draw()
    
    receive_chatmsg : (data) ->
      if data?
        @game.chat.add(data)
    
    receive_canvaspage : (data) ->
      if data?
        @game.drawingArea.drawing = ( JSON.parse(line) for line in data )
        switch @role
          when 'o', 'g'
            @game.drawingArea.draw()
      
    receive_canvasline : (data) ->
      switch @role
        when 'o', 'g'
          @game.drawingArea.add(data)
      return
      
    receive_words : (data) ->
      if @role is 'g'
        # todo.
        return
          
    receive_draw_candidate_words : (data) ->
      if @role is 'd' then @game.predrawingArea.add(data)