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
      # Welcome event received when socket.io connection is initiated
      @registerClientEvents()
    
    registerClientEvents : ->
      @socket.on(e, (r) => @["receive_#{e}"](r)) for e in [
        'playerlist'
        'canvaspage'
        'canvasline'
        'chatmsg'
        'chatlog'
      ]
    
    # TX (Transmission Send) Events # # # # # # # #
    
    send_joinroom : ->
      # Keep room and name if resuming a session
      @name = prompt('Your name', 'Player') unless @name?
      @room = prompt('Room', 'lobby')       unless @room?
      
      @socket.emit('joinroom', {
        room  : @room
        name  : @name
      })

      @game.mode.init.call(@game)
      
    send_chatmsg : (msg) ->
      @socket.emit('chatmsg', {
        name  : @name
        msg   : msg
      })
    
    # TR (Transmission Receive) Events # # # # # # # #
      
    receive_welcome : (data) ->
      @id         = data?.id
      @role       = data?.role
      @connected  = true
      @send_joinroom()
    
    receive_playerlist : (data) ->
      @game.addPlayer({ name : n }) for n in data.split(' ')
      return
    
    receive_chatlog : (data) ->
      messages = JSON.parse(data)
      @game.chat.messages = messages if messages?
      @game.chat.draw()
    
    receive_chatmsg : (data) ->
      message = JSON.parse(data)
      @game.chat.messages.push = message if message?
      @game.chat.draw()
    
    receive_canvaspage : (data) ->
      # todo: catch errors
      @game.drawingArea.drawing = data.lines
      @game.drawingArea.draw()
      
    receive_canvasline : (data) ->
      @game.drawingArea.drawing.push(data.line)
      @game.drawingArea.drawLine(data.line)