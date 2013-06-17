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
    this.SOCKET.on('canvasline', function(d) {
      return _this.receive_canvasline(d);
    });
    this.SOCKET.on('chooseword', function(d) {
      return _this.receive_chooseword(d);
    });
    this.SOCKET.on('guessword', function(d) {
      return _this.receive_guessword(d);
    });
    this.SOCKET.on('disconnect', function() {
      return _this.db_send_leaveroom;
    });
  };

  Connection.prototype.send_welcome = function() {
    this.SOCKET.emit('welcome', {
      role: 'd',
      id: 12
    });
    return this.send_draw_candidate_words();
  };

  Connection.prototype.send_draw_candidate_words = function(words) {
    var i;
    words = (function() {
      var _i, _results;
      _results = [];
      for (i = _i = 0; _i < 10; i = ++_i) {
        _results.push(this.db_choose_word());
      }
      return _results;
    }).call(this);
    return this.SOCKET.emit('drawwords', words);
  };

  Connection.prototype.db_send_chat = function() {
    return this.NETWORK.rc.hset("room:" + this.SOCKET._.room, 'chat', JSON.stringify(this.SOCKET._.JSON.chat));
  };

  Connection.prototype.db_send_playerlist = function() {
    return this.NETWORK.rc.hset("room:" + this.SOCKET._.room, 'playerlist', JSON.stringify(this.SOCKET._.JSON.playerlist));
  };

  Connection.prototype.db_send_canvasline = function(line) {
    return this.NETWORK.rc.lpush("room:" + this.SOCKET._.room + ":canvas", JSON.stringify(line));
  };

  Connection.prototype.db_choose_word = function() {
    var category, topicObj, word;
    category = ['adj', 'noun', 'verb'][$.R(0, 2)];
    topicObj = $.AR(this.WORDS[category]);
    word = $.AR(topicObj.list);
    return {
      value: word,
      category: category,
      topic: topicObj.topic
    };
  };

  Connection.prototype.db_send_room_drawwords = function() {
    var args, i;
    args = (function() {
      var _i, _results;
      _results = [];
      for (i = _i = 0; _i < 10; i = ++_i) {
        _results.push(this.db_choose_word());
      }
      return _results;
    }).call(this);
    args.unshift("room:" + this.SOCKET._.room + ":drawwords");
    return this.NETWORK.rc.sadd.apply(this, args);
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

  Connection.prototype.db_send_decr_playercount = function() {
    return this.NETWORK.rc.decr("room:" + this.SOCKET._.room + ":playercount");
  };

  Connection.prototype.db_send_incr_playercount = function() {
    return this.NETWORK.rc.incr("room:" + this.SOCKET._.room + ":playercount");
  };

  Connection.prototype.receive_hello = function(data) {
    this.SOCKET._ = data;
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

  Connection.prototype.db_receive_playercount = function(err, data) {
    return this.NETWORK.rc.get("room:" + this.SOCKET._.room + ":playercount");
  };

  Connection.prototype.db_receive_canvaslength = function(err, data) {
    var _this = this;
    return this.NETWORK.rc.lrange("room:" + this.SOCKET._.room + ":canvas", 0, data, function(e, d) {
      return _this.db_receive_canvas(e, d);
    });
  };

  Connection.prototype.db_receive_canvas = function(err, data) {
    return this.SOCKET.emit('canvaspage', data);
  };

  Connection.prototype.db_receive_room = function(err, data) {
    var j, k, v, _ref;
    if (data != null) {
      this.SOCKET._.JSON = data;
      _ref = this.SOCKET._.JSON;
      for (k in _ref) {
        v = _ref[k];
        this.SOCKET._.JSON[k] = JSON.parse(v);
      }
    } else {
      this.SOCKET._.JSON = {
        playerlist: [],
        chat: []
      };
    }
    j = this.SOCKET._.JSON;
    j.playerlist.push(this.SOCKET._.name);
    this.SOCKET.emit('playerlist', j.playerlist);
    this.SOCKET.emit('chatlog', j.chat);
    this.SOCKET.emit('words', ['cat', 'rat', 'dog', 'hog', 'fog', 'smog', 'log', 'lock', 'clock', 'block']);
    if (!(data != null)) {
      this.db_create_room();
    }
    this.db_send_playerlist();
  };

  Connection.prototype.receive_joinroom = function(data) {
    var _this = this;
    this.SOCKET._ = $.extend(this.SOCKET._, data);
    this.NETWORK.rc.hgetall("room:" + data.room, function(e, d) {
      return _this.db_receive_room(e, d);
    });
    this.NETWORK.rc.llen("room:" + data.room + ":canvas", function(e, d) {
      return _this.db_receive_canvaslength(e, d);
    });
  };

  Connection.prototype.receive_leaveroom = function(data) {
    var j;
    j = this.SOCKET._.JSON;
    j.playerlist = j.playerlist.splice(j.playerlist.indexOf(this.SOCKET._.name), 1);
    this.db_send_playerlist();
    this.db_send_decr_playercount();
  };

  Connection.prototype.receive_canvasline = function(data) {
    var j;
    j = this.SOCKET._.JSON;
    this.db_send_canvasline(data);
    this.NETWORK.io.emit('canvasline', data);
  };

  Connection.prototype.receive_chooseword = function(data) {};

  Connection.prototype.receive_guessword = function(data) {};

  return Connection;

})();

module.exports = Connection;
