$ = require('./$.js')

class Connection
  
  constructor : (params) ->
    # extend the prototype with constructor params
    @[k] = v for k,v of params 
    @registerEvents()
    # Tell the player client we're clear to receive more info!
    @SOCKET.emit('welcome')
    @
  
  NETWORK : null
  SOCKET  : null
  
  registerEvents : ->
    @SOCKET.on('joinroom', (d) => @event.joinroom.call(@, d))
    
    @
  
  # What happens when we receive these kinds of messages from a player client's connection?
  event :
    
    joinroom : (data) ->
      # Save the client's settings
      @SOCKET._ = $.extend({}, data)
    
      # d = response data
      # e = error (if any)
      @NETWORK.rc.get("room #{data.room} canvaspage", (e,d) => @SOCKET.emit('canvaspage', d))
      @NETWORK.rc.get("room #{data.room} chatlog",    (e,d) => @SOCKET.emit('chatlog', d))
      @NETWORK.rc.get("room #{data.room} playerlist", (e,d) =>
        # Add our new player
        newPlayerList = if d? then "#{d} #{data.name}" else "#{data.name}"
        @SOCKET.emit('playerlist', newPlayerList)
        @NETWORK.rc.set("room #{data.room} playerlist", newPlayerList)
      )
      return
    
    leaveroom : (data) ->
      @NETWORK.rc.get("room #{@SOCKET._.room} playerlist", (e,d) =>
        # fixme: make sure this works. Remove our player
        newPlayerList = d.replace(" #{@SOCKET._.name}",'').replace("#{@SOCKET._.name}",'') unless !(d?)
        @NETWORK.rc.set("room #{@SOCKET._.room} playerlist", newPlayerList)
      )
      return
      
    canvasline : (data) ->
    canvaspage : (data) ->
    chatlog : (data) ->
    chatmsg : (data) ->


module.exports = Connection