// Generated by CoffeeScript 1.4.0
var Connection, Player;

Player = require('./player.js');

Connection = (function() {

  function Connection(params) {
    var k, v;
    for (k in params) {
      v = params[k];
      this[k] = v;
    }
    this;

  }

  Connection.playerJoin = function(data) {};

  Connection.disconnect = function(data) {};

  Connection.addLine = function(data) {};

  Connection.sendMessage = function(data) {};

  Connection.guessWord = function(data) {};

  return Connection;

})();

module.exports = Connection;
