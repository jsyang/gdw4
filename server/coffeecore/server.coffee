do ( ->
  redis     = require('redis')
  http      = require('http')
  fs        = require('fs')
  socket_io = require('socket.io')
  cxn       = require('./connection.js')
  
  # Update this when you add new word lists.
  WORDS =
    adj : [
      'humans'
    ]
    noun : [
      'animals'
      'books'
      'bugs'
      'buildings'
      'features'
      'jobs'
      'pets'
      'restaurant'
    ]
    verb : [
      'gardening'
    ]
  
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
    rc    : redis.createClient() # we can host the redis server elsewhere but for now, run it locally
    io    : socket_io.listen(HTTPhandler).set('log level', 1).sockets
    # Fixme: Maybe not totally necessary yet...
    #db_send_words_exist_check : ->
    #  @rc.multi()
    #    .exists("words:adj:#{WORDS.adj[0]}")
    #    .exists("words:noun:#{WORDS.noun[0]}")
    #    .exists("words:verb:#{WORDS.verb[0]}")
    #    .exec((e, r) => @db_receive_words_exist_check(e,r))
    #
    #db_receive_words_exist_check : (err, replies) ->
    #  wordSetsExist = true
    #  wordSetsExist &= bool for bool in replies
    #  @db_send_words() unless wordSetExist
    #
    #db_send_words : ->
    #  multiCmd = @rc.multi()
    #  (
    #    args = []
    #    multiCmd.sadd("words:#{k}")
    #  ) for k,v in WORDS
    #  fs.read
    #  return
  # Check to see if DB has the word list! If not, then load the list from disk and populate it!    
  #network.db_send_words_exist_check()
  
  # Load all the words into the obj.
  # todo: offload this to the DB
  (
    j = 0
    (
      WORDS[k][j] =
        topic : i
        list  : fs.readFileSync("words/#{k}/#{i}.txt").toString().split('\n')
      j++
    ) for i in v
  ) for k,v of WORDS
  
  # Use same __ namespace for all connections.
  cxn.prototype.NETWORK = network
  cxn.prototype.WORDS   = WORDS
  
  # Listen to connections.
  network.rc.on('error', (err) -> console.log("Error : #{err}"))
  network.io.on('connection', (sock) ->
    new cxn({ SOCKET : sock })
  )
  
)