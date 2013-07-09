$ = require('./$.js')

class Connection
  DATA    : null  # temp data for this connection.
  NETWORK : null
  SOCKET  : null
  
  constructor : (params) ->
    @[k] = v for k,v of params 
    @registerServerEvents()
    # Init data.
    @DATA = {}
    
  registerServerEvents : ->
    @SOCKET.on('hello',       (d) => @receive_hello(d))
    @SOCKET.on('joinroom',    (d) => @receive_joinroom(d))
    @SOCKET.on('chatmsg',     (d) => @receive_chatmsg(d))
    @SOCKET.on('canvasline',  (d) => @receive_canvasline(d))
    @SOCKET.on('chooseword',  (d) => @receive_chooseword(d))
    @SOCKET.on('guessword',   (d) => @receive_guessword(d))
    
    @SOCKET.on('disconnect',  => @db_send_leaveroom)
    return
  
  # Outgoing events = send_...    / db_send_...
  # Incoming events = receive_... / db_receive_...
  # Func defs in chronological order of connection events.
  
  # PHASE 1 - Preamble
  
  receive_hello : (data) ->
    @DATA.room = data
    @NETWORK.rc.hgetall(  "room:#{data}:round",    (e,d) => @db_receive_round(e,d))          # Get current state of the round.
    @NETWORK.rc.lrange(   "room:#{data}:players",  0, -1, (e,d) => @db_receive_players(e,d)) # Get all the players in the room.
    @NETWORK.rc.llen(     "room:#{data}:canvas",   (e,d) => @db_receive_canvaslength(e,d))   # Get the contents of the room's whiteboard.
    @NETWORK.rc.llen(     "room:#{data}:chat",     (e,d) => @db_receive_chatlength(e,d))     # Get chat log.
    return
  
  db_receive_players : (err, data) ->
    @DATA.players = data
    console.log('db_receive_players',data)
    @SOCKET.emit('players', data)
    
  db_receive_round : (err, data) ->
    @DATA.round = data
    @SOCKET.emit('round', data)
  
  db_receive_canvaslength : (err, data) ->
    @NETWORK.rc.lrange("room:#{@DATA.room}:canvas", 0, data, (e,d) => @db_receive_canvas(e,d))
  
  db_receive_canvas : (err, data) ->
    @DATA.canvas = data
    @SOCKET.emit('canvaspage', data)
    
  db_receive_chatlength : (err, data) ->
    # Last 40 messages only
    start = data - 40
    if start < 0 then start = 0
    @NETWORK.rc.lrange("room:#{@DATA.room}:chat", start, data, (e,d) => @db_receive_chat(e,d))
  
  db_receive_chat : (err, data) ->
    @DATA.chat = data
    @SOCKET.emit('chat', data)
  
  # PHASE 2 - Intro
  
  receive_joinroom : (data) ->
    if data?
      if @DATA.players.indexOf(data) is -1
        @db_send_add_player(data)
        @NETWORK.rc.hgetall("room:#{@DATA.room}:round", (e,d) => @db_receive_roundstate(e,d))
      else
        @SOCKET.emit('error:joinroom',"Sorry, '#{data}' is already taken!")
    return
  
  db_send_add_player : (name) ->
    @DATA.name = name
    @NETWORK.rc.lpush("room:#{@DATA.room}:players", name)
  
  db_receive_roundstate : (err, data) ->
    @DATA.round = data
    @SOCKET.emit('round', data)
    
    # todo : take care of when to start rounds and such
    if data.state is 'active'
      @NETWORK.rc.lindex("room:#{@DATA.room}:", -1, (e,d) => )
    else if data.state is 'idle'
      # 1. check if time is ripe to choose the drawer for the next round
      @choose_drawer()
    else if data.state is 'over'
      # 1. check if time is ripe to choose the drawer for the next round
      @choose_drawer()
    return
  
  choose_drawer : ->
    # Get the next person in the rotation as the drawer then send him to the end of the line.
    @NETWORK.rc.rpoplpush("room:#{@DATA.room}:players", (e,d) => @db_receive_drawer(e,d))
  
  db_receive_drawer : (err, data) ->
    @DATA.drawer = data
    @NETWORK.io.emit('round:drawer', data)
    if @DATA.name is @DATA.drawer
      wordpool = (@random_word() for i in [0...10]) # Choose 10 words to give the drawer
      @SOCKET.emit('round:drawer:words', wordpool)
      
  random_word : (category = $.AR(['adj', 'noun', 'verb']), topic, omitWords = ['--nothing1--', '--nothing2--']) ->
    topicObj  = if topic? then topic else $.AR(@WORDS[category])
    word = $.AR(topicObj.list)
    word = $.AR(topicObj.list) until word is not omitWords[0] and word is not omitWords[1]
    {
      category  : category
      topic     : topicObj.topic
      value     : word
    }
  
  receive_choosen_words : (data) ->
    @DATA.chosenWords = data
    chosenWords = data
    decoyWords = [
      chosenWords[0].value
      chosenWords[1].value
    ]
    decoyWords = decoyWords.append((@random_word(chosenWords[0].category, chosenWords[0].topic, chosenWords[0].value).value for i in [0...2]))
    decoyWords = decoyWords.append((@random_word(chosenWords[1].category, chosenWords[1].topic, chosenWords[1].value).value for i in [0...2]))
    # Clear the previous words.
    @NETWORK.rc.sinterstore("room:#{@DATA.room}:words", decoyWords)
    @NETWORK.io.emit("words", decoyWords)
    
    @send_roundstart()
    return
  
  # Todo : round event triggers from the node server
  # PHASE 3 - Round in progress
  
  send_roundstart : ->
    @SOCKET.emit('round:start', {
      endTime : 2*60*1000 + new Date()
    })
    
  receive_guessword : (data) ->
    # 1. mark the guessed words as used
    # 2. check if words are correct, mark correctness / incorrectness
    # 3. end the player's turn if they chose their 2nd word
    # 4. if both correct, end the round
    # 5. call broadcast function to show the stats
  
  receive_canvasline : (data) ->
    j = @SOCKET._.JSON
    @db_send_canvasline(data)
    # todo: pub/sub for rooms
    @NETWORK.io.emit('canvasline', data)
    return
  
  
  db_send_canvasline : (line) -> @NETWORK.rc.lpush("room:#{@SOCKET._.room}:canvas", JSON.stringify(line))
  
  # PHASE 4 - Metagame
  
  # todo: use a redis list
  db_send_chat : -> @NETWORK.rc.hset("room:#{@DATA.room}",'chat', JSON.stringify(@DATA.chat))
    
  receive_chatmsg : (data) ->
    j = @DATA
    j.chat.push(data)
    j.chat = j.chat[j.chat.length-20..] if j.chat.length > 20
    @db_send_chat()
    @NETWORK.io.emit('chatmsg', data)  
  
  db_send_leaveroom : (data) ->
    # Remove player from the rotation.
    @NETWORK.rc.lrem("room:#{@DATA.room}:players", 0, data)
    @NETWORK.io.emit('playerleft', data)
    return

    
module.exports = Connection