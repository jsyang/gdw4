// Generated by CoffeeScript 1.4.0

define(function() {
  var PredrawingArea;
  return PredrawingArea = (function() {

    PredrawingArea.prototype.x = 0;

    PredrawingArea.prototype.y = 0;

    PredrawingArea.prototype.w = 600;

    PredrawingArea.prototype.h = 400;

    PredrawingArea.prototype.margin = 16;

    PredrawingArea.prototype.FONTSIZE = 20;

    PredrawingArea.prototype.words = [];

    function PredrawingArea(params) {
      var k, v;
      for (k in params) {
        v = params[k];
        this[k] = v;
      }
      if (!(this.game != null)) {
        throw 'game was not set!';
      }
      this.resize();
    }

    PredrawingArea.prototype.addWord = function(word) {
      words.push(word);
      return this;
    };

    PredrawingArea.prototype.setTextStyle = function() {
      var ac;
      ac = atom.context;
      ac.textBaseline = 'middle';
      ac.textAlign = 'center';
      ac.font = "bold " + this.FONTSIZE + "px sans-serif";
      ac.fillStyle = '#000';
      return this;
    };

    PredrawingArea.prototype.draw = function() {
      var ac;
      ac = atom.context;
      ac.clearRect(this.x, this.y, this.w, this.h);
      ac.fillStyle = '#eee';
      ac.fillRect(this.x, this.y, this.w, this.h);
      this.setTextStyle();
      if (this.game.network.role === 'd') {
        ac.fillText("Choose 2 words to draw", this.x + (this.w >> 1), this.y + (this.FONTSIZE >> 1) + this.margin);
      } else {
        ac.fillText("Waiting on " + this.game.network.whoseTurn + " to draw...", this.x + (this.w >> 1), this.y + (this.h >> 1));
      }
      return this;
    };

    PredrawingArea.prototype.resize = function() {
      this.x = this.margin;
      this.y = this.margin;
      return this;
    };

    return PredrawingArea;

  })();
});