// Generated by CoffeeScript 1.4.0
var $, Connection;

$ = require('./$.js');

Connection = (function() {

  Connection.prototype.NETWORK = null;

  Connection.prototype.SOCKET = null;

  function Connection(params) {
    var k, v;
    for (k in params) {
      v = params[k];
      this[k] = v;
    }
    this.registerServerEvents();
  }

  Connection.prototype.registerServerEvents = function() {
    var _this = this;
    this.SOCKET.on('hello', function(d) {
      return _this.receive_hello(d);
    });
    this.SOCKET.on('joinroom', function(d) {
      return _this.receive_joinroom(d);
    });
    this.SOCKET.on('chatmsg', function(d) {
      return _this.receive_chatmsg(d);
    });
  };

  Connection.prototype.send_welcome = function() {
    return this.SOCKET.emit('welcome', {
      role: 'd',
      id: 12
    });
  };

  Connection.prototype.db_send_chat = function() {
    return this.NETWORK.rc.hset("room:" + this.SOCKET._.room, 'chat', JSON.stringify(this.SOCKET._.JSON.chat));
  };

  Connection.prototype.db_send_playerlist = function() {
    return this.NETWORK.rc.hset("room:" + this.SOCKET._.room, 'playerlist', JSON.stringify(this.SOCKET._.JSON.playerlist));
  };

  Connection.prototype.db_create_room = function() {
    var j, k, roomDict, v;
    j = this.SOCKET._.JSON;
    roomDict = {};
    for (k in j) {
      v = j[k];
      roomDict[k] = JSON.stringify(v);
    }
    return this.NETWORK.rc.hmset("room:" + this.SOCKET._.room, roomDict);
  };

  Connection.prototype.receive_hello = function() {
    return this.send_welcome();
  };

  Connection.prototype.receive_chatmsg = function(data) {
    var j;
    j = this.SOCKET._.JSON;
    j.chat.push(data);
    if (j.chat.length > 20) {
      j.chat = j.chat.slice(j.chat.length - 20);
    }
    this.db_send_chat();
    return this.NETWORK.io.emit('chatmsg', data);
  };

  Connection.prototype.db_receive_room = function(err, data, cb) {
    var j, k, v, _ref;
    if (data != null) {
      this.SOCKET._.JSON = data;
      _ref = this.SOCKET._.JSON;
      for (k in _ref) {
        v = _ref[k];
        this.SOCKET._.JSON[k] = JSON.parse(v);
      }
      console.log(this.SOCKET._.JSON);
    } else {
      this.SOCKET._.JSON = {
        playerlist: [],
        chat: [],
        canvas: []
      };
    }
    j = this.SOCKET._.JSON;
    this.SOCKET.emit('playerlist', j.playerlist);
    this.SOCKET.emit('chatlog', j.chat);
    this.SOCKET.emit('canvaspage', j.canvas);
    this.SOCKET.emit('words', ['cat', 'rat', 'dog', 'hog', 'fog', 'smog', 'log', 'lock', 'clock', 'block']);
    if (!(data != null)) {
      this.db_create_room();
    }
    j.playerlist.push(this.SOCKET._.name);
    this.db_send_playerlist();
  };

  Connection.prototype.receive_joinroom = function(data) {
    var _this = this;
    this.SOCKET._ = data;
    this.NETWORK.rc.hgetall("room:" + data.room, function(e, d) {
      return _this.db_receive_room(e, d);
    });
  };

  Connection.prototype.receive_leaveroom = function(data) {
    var j;
    j = this.SOCKET._.JSON;
    j.playerlist = j.playerlist.splice(j.playerlist.indexOf(this.SOCKET._.name), 1);
    this.db_send_playerlist();
  };

  Connection.prototype.receive_canvasline = function(data) {};

  return Connection;

})();

module.exports = Connection;
