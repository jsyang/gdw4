// Generated by CoffeeScript 1.4.0

define(function() {
  var Player;
  return Player = (function() {

    Player.prototype.score = 0;

    Player.prototype.roomID = null;

    Player.prototype.name = null;

    Player.prototype.photoURL = null;

    Player.prototype.role = null;

    Player.prototype.active = false;

    function Player(params) {
      var k, v;
      for (k in params) {
        v = params[k];
        this[k] = v;
      }
    }

    return Player;

  })();
});
