$ = require('./$.js')

class Connection
  NETWORK : null
  SOCKET  : null
  
  constructor : (params) ->
    @[k] = v for k,v of params 
    @registerServerEvents()
    
  registerServerEvents : ->
    @SOCKET.on('hello',     (d) => @receive_hello(d))
    @SOCKET.on('joinroom',  (d) => @receive_joinroom(d))
    @SOCKET.on('chatmsg',   (d) => @receive_chatmsg(d))
    @SOCKET.on('canvasline',(d) => @receive_canvasline(d))
    @SOCKET.on('chooseword',(d) => @receive_chooseword(d))
    @SOCKET.on('guessword', (d) => @receive_guessword(d))
    
    return
  
  # TX (Transmission Send) Events
  
  send_welcome : ->
    # todo : assign the player their role
    @SOCKET.emit('welcome', {
      role  : 'd'
      id    : 12
    })
  
  send_words : ->
    # send the updated (already chosen word list)
    # todo
  
  db_send_chat        : -> @NETWORK.rc.hset("room:#{@SOCKET._.room}",'chat', JSON.stringify(@SOCKET._.JSON.chat))
  db_send_playerlist  : -> @NETWORK.rc.hset("room:#{@SOCKET._.room}",'playerlist', JSON.stringify(@SOCKET._.JSON.playerlist))
  db_send_canvasline  : (line) -> @NETWORK.rc.lpush("room:#{@SOCKET._.room}:canvas", JSON.stringify(line))
  
  db_create_room : ->
    j = @SOCKET._.JSON
    roomDict = {}
    roomDict[k] = JSON.stringify(v) for k,v of j
    @NETWORK.rc.hmset("room:#{@SOCKET._.room}", roomDict)
    
  # TR (Transmission Receive) Events
    
  receive_hello : -> @send_welcome()
    
  receive_chatmsg : (data) ->
    j = @SOCKET._.JSON
    j.chat.push(data)
    j.chat = j.chat[j.chat.length-20..] if j.chat.length > 20
    @db_send_chat()
    @NETWORK.io.emit('chatmsg', data)
  
  db_receive_canvaslength : (err, data) ->
    @NETWORK.rc.lrange("room:#{@SOCKET._.room}:canvas", 0, data, (e,d) => @db_receive_canvas(e,d))
  
  db_receive_canvas : (err, data) ->
    @SOCKET.emit('canvaspage', data)
  
  db_receive_room : (err, data) ->
    if data?
      @SOCKET._.JSON = data
      (@SOCKET._.JSON[k] = JSON.parse(v)) for k,v of @SOCKET._.JSON
    else
      @SOCKET._.JSON =
        playerlist  : []
        chat        : []
    
    j = @SOCKET._.JSON
    j.playerlist.push(@SOCKET._.name) # Add player to the room
  
    @SOCKET.emit('playerlist', j.playerlist)
    @SOCKET.emit('chatlog',    j.chat)
    
    # Pick words to give the player
    @SOCKET.emit('words', [
      'cat'
      'rat'
      'dog'
      'hog'
      'fog'
      'smog'
      'log'
      'lock'
      'clock'
      'block'
    ])
    
    
    if !data?
      @db_create_room()
    
    @db_send_playerlist()
    return
    
  receive_joinroom : (data) ->
    @SOCKET._ = data
    @NETWORK.rc.hgetall("room:#{data.room}",      (e,d) => @db_receive_room(e,d))
    @NETWORK.rc.llen("room:#{data.room}:canvas",  (e,d) => @db_receive_canvaslength(e,d))
    return
  
  receive_leaveroom : (data) ->
    j = @SOCKET._.JSON
    j.playerlist = j.playerlist.splice(j.playerlist.indexOf(@SOCKET._.name), 1)
    @db_send_playerlist()
    return
    
  receive_canvasline : (data) ->
    j = @SOCKET._.JSON
    @db_send_canvasline(data)
    @NETWORK.io.emit('canvasline', data)
    return
    
  receive_chooseword : (data) ->
    return
    
  receive_guessword : (data) ->
    return
    
module.exports = Connection