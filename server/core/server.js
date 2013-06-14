// Generated by CoffeeScript 1.4.0

(function() {
  var HTTPhandler, cxn, fs, http, io, registerCxnEvents, socket_io, _cxns;
  http = require('http');
  fs = require('fs');
  socket_io = require('socket.io');
  cxn = require('./connection.js');
  HTTPhandler = http.createServer(function(req, res) {
    return fs.readFile("" + __dirname + "/index.html", function(err, data) {
      if (err != null) {
        res.writeHead(500);
        return res.end('Error serving index.html!');
      } else {
        res.writeHead(200);
        return res.end(data);
      }
    });
  }).listen(8000);
  registerCxnEvents = function(socket) {
    var e, _i, _len, _ref;
    _ref = ['playerJoin', 'disconnect', 'addLine', 'sendMessage', 'guessWord'];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      e = _ref[_i];
      socket.on(e, cxn[e]);
    }
    return socket;
  };
  _cxns = [];
  io = socket_io.listen(HTTPhandler).sockets;
  return io.on('connection', function(sock) {
    registerCxnEvents(sock);
    _cxns.push(new cxn({
      id: sock.id,
      ip: sock.handshake.address.address,
      socket: sock
    }));
    return sock.emit('welcome', {
      hi: 1
    });
  });
})();
