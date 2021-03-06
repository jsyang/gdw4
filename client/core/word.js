// Generated by CoffeeScript 1.4.0

define(function() {
  var Word;
  return Word = (function() {

    Word.prototype.x = 0;

    Word.prototype.y = 0;

    Word.W = 240;

    Word.H = 60;

    Word.prototype.w = 240;

    Word.prototype.h = 40;

    Word.prototype.margin = 16;

    Word.prototype.FONTSIZE = 20;

    Word.prototype.value = null;

    Word.prototype.chosen = false;

    Word.prototype.correct = false;

    Word.prototype.type = 'predrawing';

    Word.prototype.index = -1;

    function Word(params) {
      var k, v;
      for (k in params) {
        v = params[k];
        this[k] = v;
      }
    }

    Word.prototype.setTextStyle = function() {
      var ac;
      ac = atom.context;
      ac.textBaseline = 'middle';
      ac.textAlign = 'center';
      ac.font = "bold " + this.FONTSIZE + "px sans-serif";
      if (this.type === 'predrawing') {
        ac.fillStyle = this.chosen ? '#4EB581' : '#000';
      } else {
        ac.fillStyle = '#000';
      }
      return this;
    };

    Word.prototype.clear = function() {
      var ac;
      ac = atom.context;
      ac.clearRect(this.x, this.y, this.w, this.h);
      return this;
    };

    Word.prototype.draw = function() {
      var ac, keyToPress;
      ac = atom.context;
      this.clear();
      ac.strokeStyle = '#000';
      ac.lineWidth = 1;
      ac.fillStyle = '#eee';
      ac.fillRect(this.x, this.y, this.w, this.h);
      ac.strokeRect(this.x + 1, this.y + 1, this.w - 2, this.h - 2);
      this.setTextStyle();
      keyToPress = this.index + 1;
      if (keyToPress > 9) {
        keyToPress = 0;
      }
      ac.fillText("[" + this.index + "] " + this.value, this.x + (this.w >> 1), this.y + (this.h >> 1));
      return this;
    };

    return Word;

  })();
});
