var app = require('http').createServer(handler)
  , io = require('socket.io').listen(app)
  , fs = require('fs')
  , players = require('./Players.js')
  , canvas = require('./Canvas.js')

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
canvas.init();

canvas.addLine(1,2,3,4);
canvas.addLine(5,6,7,8);
canvas.addLine(9,10,11,12);


io.sockets.on('connection', function (socket) {

  socket.on('playerJoin', function (data) {
        var ip = socket.handshake.address.address;
        var p = players.addPlayer({
            playerId: socket.id,
            clientIp: ip,
            name: data.playerName
        });
        console.log('SOCKET.IO player added: '+ p.name + ' from '+ ip + ' for socket '+ socket.id);
        emitPlayerUpdate(socket);
        if (players.getPlayerCount() == 1) {
            // start game!
            //emitNewQuestion();
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
	  canvas.addLine(data.x1, data.y1, data.x2, data.y2);
	  console.log('SOCKET.IO added line: ' + data); 
	  emitCanvasUpdate();
  }

  socket.emit('welcome', { hello: 'world' });
  socket.on('my other event', function (data) {
    console.log(data);
  });
});


function emitPlayerUpdate(socket) {
    var playerData = players.getPlayerData();
    if (socket) {
        socket.broadcast.emit('players', playerData); // emit to all but socket 
        playerData.msg = 'Welcome, '+ players.getPlayerName(socket.id);
        socket.emit('players', playerData); // emit only to socket
        
    } else {
        io.sockets.emit('players', playerData); // emit to everyone (points update)
    }
}

function emitCanvasUpdate(socket) {
    io.sockets.emit('canvas', canvas.getLines()); // emit to everyone
}

