var app = require('http').createServer(handler)
  , io = require('socket.io').listen(app)
  , fs = require('fs')
  , players = require('./Players.js')
  , canvas = require('./Canvas.js')
  , chat = require('./Chat.js')

app.listen(8080);

function handler (req, res) {
  fs.readFile(__dirname + '/index.html',
  function (err, data) {
    if (err) {
      res.writeHead(500);
      return res.end('Error loading index.html');
    }

    res.writeHead(200);
    res.end(data);
  });
}

players.init();

players.setWords([ "blue", "car", "purple", "monkey", "orange", "bear"]);
players.setWinningWords(["purple", "monkey"]);

canvas.init();
chat.init();

io.sockets.on('connection', function (socket) {

  socket.on('playerJoin', function (data) {
        var ip = socket.handshake.address.address;
        var p = players.addPlayer({
            playerId: socket.id,
            clientIp: ip,
            name: data.playerName,
            role: data.role
        });
        console.log('SOCKET.IO player added: '+ p.name + ' from '+ ip + ' for socket '+ socket.id);
        emitPlayerUpdate();
        emitCanvasUpdate();
        emitChatUpdate();

        if (players.getPlayerCount() == 1) {
            emitRoundStartedEvent();
        }
  });

  socket.on('disconnect', function() {
        var pname = players.getPlayerName(socket.id);
        console.log('SOCKET.IO player disconnect: '+ pname + ' for socket '+ socket.id);
        if (!pname) {
            // already disconnected
              return;
        }
        players.removePlayer(socket.id);
        emitPlayerUpdate();
  });
  
  socket.on('addLine', function(data) {
	  canvas.addLine(data);
	  console.log('SOCKET.IO added line: ' + data); 
	  emitCanvasUpdate();
  });
  
  socket.on('sendMessage', function(data) {
	 
	  var pname = players.getPlayerName(socket.id); 
	  data.name = pname;
	  chat.sendMessage(data);
	  console.log('SOCKET.IO sent message: ' + data); 
	  emitChatUpdate();
  });
  
   socket.on('guessWord', function(data) {
	 
	  if(players.guessWord(data, socket.id)) {
	  
		  var pname = players.getPlayerName(socket.id); 
	
		  chat.sendMessage({ message: pname +" guessed '" + data.word + "'" });
		  emitPlayerUpdate(); 
		  emitChatUpdate();
		  
          if(players.roundIsOver()) {
	          emitRoundEndedEvent();
          }
	  }
  });

  socket.emit('welcome', { hello: 'world' });
  socket.on('my other event', function (data) {
    console.log(data);
  });
});


function emitPlayerUpdate() {
    var playerData = players.getPlayerData();
    io.sockets.emit('players', playerData); // emit to everyone (points update)
    
}

function emitCanvasUpdate() {
    var canvasData = canvas.getCanvasData();
    io.sockets.emit('canvas', canvasData); // emit to everyone
}

function emitChatUpdate() {
    var chatData = chat.getChatData();
    io.sockets.emit('chat', chatData); // emit to everyone
}


function emitRoundStartedEvent() {
    io.sockets.emit('roundStarted'); // emit to everyone
}

function emitRoundEndedEvent() {
    io.sockets.emit('roundEnded'); // emit to everyone
}

