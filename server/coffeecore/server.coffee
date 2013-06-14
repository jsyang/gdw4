do ( ->

  http      = require('http')
  fs        = require('fs')
  socket_io = require('socket.io')
  #player    = require('./core/player.js')
  #canvas    = require('./core/canvas.js')
  #chat      = require('./core/chat.js')
  
  cxn       = require('./connection.js')
  
  # HTTP request handler
  HTTPhandler = http.createServer(
    (req, res) ->
      fs.readFile(
        "#{__dirname}/index.html",
        (err, data) ->
          # What to do with our index page when reading attempt ends.
          if err?
            res.writeHead(500)
            res.end('Error serving index.html!')
          else
            res.writeHead(200)
            res.end(data)
      )
  ).listen(8000)
  
  # Events to listen to once someone's connected, use funcs inside the cxn module.
  registerCxnEvents = (socket) ->
    for e in [
      'playerJoin'
      'disconnect'
      'addLine'
      'sendMessage'
      'guessWord'
    ]
      socket.on(e, cxn[e])
    socket
  
  # Todo: Store connection objs in a better fashion
  _cxns = []
  
  # socket.io events
  io = socket_io.listen(HTTPhandler).sockets 
  io.on('connection', (sock) ->
    registerCxnEvents(sock)
    # Todo : keep track of connections somehow. schema unclear yet
    _cxns.push(new cxn({
      id      : sock.id
      ip      : sock.handshake.address.address
      socket  : sock
    }))
    
    # Tell client we're successfully connected.
    sock.emit('welcome', { hi : 1 })
  )
  
)