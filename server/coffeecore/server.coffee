do ( ->
  redis     = require('redis')
  http      = require('http')
  fs        = require('fs')
  socket_io = require('socket.io')
  cxn       = require('./connection.js')
  
  # Doesn't seem like we'll need these extra classes if we manage
  # the data through the datastore in a clever manner.
  #player    = require('./core/player.js')
  #canvas    = require('./core/canvas.js')
  #chat      = require('./core/chat.js')
  
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
  
  # Connect to Redis server
  network =
    rc  : redis.createClient() # we can host the redis server elsewhere but for now, run it locally
    io  : socket_io.listen(HTTPhandler).sockets

    
  # Bind our network.
  cxn.prototype.NETWORK = network
  
  network.rc.on('error', (err) -> console.log("Error : #{err}"))
  network.io.on('connection', (sock) ->
    conn = new cxn({ SOCKET : sock })
  )
  
)