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
    return
  
  # TX (Transmission Send) Events
  
  send_welcome : ->
    # todo : assign the player their role
    @SOCKET.emit('welcome', {
      role  : 'd'
      id    : 12
    })
    
  db_send_chat : -> @NETWORK.rc.hset("room:#{@SOCKET._.room}",'chat', JSON.stringify(@SOCKET._.JSON.chat))
  db_send_playerlist : -> @NETWORK.rc.hset("room:#{@SOCKET._.room}",'playerlist', JSON.stringify(@SOCKET._.JSON.playerlist))
  
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
    if j.chat.length > 20
      j.chat = j.chat[j.chat.length-20..]
    @db_send_chat()
    @NETWORK.io.emit('chatmsg', data) # broadcast.
  
  db_receive_room : (err, data, cb) ->
    if data?
      @SOCKET._.JSON = data
      (@SOCKET._.JSON[k] = JSON.parse(v)) for k,v of @SOCKET._.JSON
      console.log(@SOCKET._.JSON)
    else
      @SOCKET._.JSON =
        playerlist  : []
        chat        : []
        canvas      : []
    
    j = @SOCKET._.JSON
  
    @SOCKET.emit('playerlist', j.playerlist)
    @SOCKET.emit('chatlog',    j.chat)
    @SOCKET.emit('canvaspage', j.canvas)
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
    
    # Add player to the room
    j.playerlist.push(@SOCKET._.name)
    @db_send_playerlist()
    
    return
    
  receive_joinroom : (data) ->
    @SOCKET._ = data
    @NETWORK.rc.hgetall("room:#{data.room}", (e,d) => @db_receive_room(e,d))
    return
  
  receive_leaveroom : (data) ->
    j = @SOCKET._.JSON
    j.playerlist = j.playerlist.splice(j.playerlist.indexOf(@SOCKET._.name), 1)
    @db_send_playerlist()
    return
    
  receive_canvasline : (data) ->
  

module.exports = Connection