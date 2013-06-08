// Generated by CoffeeScript 1.4.0

define(function() {
  var StageTitle;
  return StageTitle = (function() {

    StageTitle.prototype.SPRITENAME = null;

    StageTitle.prototype.GFX = {
      'roundover': {
        W: 300,
        H: 100,
        W_2: 150,
        H_2: 50,
        LIFETIME: 300
      }
    };

    StageTitle.prototype.draw = function() {
      var ac;
      ac = atom.context;
      if (this.lifetime < 40) {
        ac.globalAlpha = this.lifetime * 0.025;
      }
      ac.drawImage(atom.gfx[this.SPRITENAME], (atom.width >> 1) - this.GFX[this.SPRITENAME].W_2, (atom.height >> 1) - this.GFX[this.SPRITENAME].H_2);
      if (this.lifetime < 40) {
        ac.globalAlpha = 1;
      }
    };

    StageTitle.prototype.remove = function() {
      this.move = null;
      return this.game = null;
    };

    StageTitle.prototype.move = function() {
      if (this.lifetime > 0) {
        this.lifetime--;
      } else {
        this.remove();
      }
    };

    function StageTitle(params) {
      var k, v;
      for (k in params) {
        v = params[k];
        this[k] = v;
      }
      this.lifetime = this.GFX[this.SPRITENAME].LIFETIME;
    }

    return StageTitle;

  })();
});
