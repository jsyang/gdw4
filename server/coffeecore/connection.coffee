$ = require('./$.js')

class Connection
  NETWORK : null
  SOCKET  : null
  
  constructor : (params) ->
    @[k] = v for k,v of params 
    @registerServerEvents()
    @send_welcome() # Send the player a welcome event when they connect.
  
  registerServerEvents : ->
    @SOCKET.on(e, (r) => @["receive_#{e}"](r)) for e in [
      'joinroom'
      'chatmsg'
    ]
  
  # TX (Transmission Send) Events
  
  send_welcome : ->
    @SOCKET.emit('welcome', {
      role  : 'g'
      id    : 12
    })
  
  # TR (Transmission Receive) Events
  
  receive_chatmsg : (data) ->
    if data?.name? and data?.msg?
      @NETWORK.rc.set("room:#{@SOCKET._.room} chatlog", newPlayerList)
  
  receive_joinroom : (data) ->
    # Save the client's settings
    @SOCKET._ = $.extend({}, data)

    # d = response data
    # e = error (if any)
    @NETWORK.rc.get("room:#{data.room} canvaspage", (e,d) => @SOCKET.emit('canvaspage', d))
    @NETWORK.rc.get("room:#{data.room} chatlog",    (e,d) => @SOCKET.emit('chatlog', d))
    @NETWORK.rc.get("room:#{data.room} playerlist", (e,d) =>
      # Add our new player
      newPlayerList = if d? then "#{d} #{data.name}" else "#{data.name}"
      @SOCKET.emit('playerlist', newPlayerList)
      @NETWORK.rc.set("room #{data.room} playerlist", newPlayerList)
    )
    return
  
  receive_leaveroom : (data) ->
    @NETWORK.rc.get("room #{@SOCKET._.room} playerlist", (e,d) =>
      # fixme: make sure this works. Remove our player
      newPlayerList = d.replace(" #{@SOCKET._.name}",'').replace("#{@SOCKET._.name}",'') unless !(d?)
      @NETWORK.rc.set("room #{@SOCKET._.room} playerlist", newPlayerList)
    )
    return
    
  receive_canvasline : (data) ->
  receive_chatmsg : (data) ->
  

module.exports = Connection