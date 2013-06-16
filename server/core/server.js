// Generated by CoffeeScript 1.4.0

(function() {
  var HTTPhandler, cxn, fs, http, network, redis, socket_io;
  redis = require('redis');
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
  network = {
    rc: redis.createClient(),
    io: socket_io.listen(HTTPhandler).set('log level', 1).sockets
  };
  cxn.prototype.NETWORK = network;
  network.rc.on('error', function(err) {
    return console.log("Error : " + err);
  });
  return network.io.on('connection', function(sock) {
    return new cxn({
      SOCKET: sock
    });
  });
})();
