// Generated by CoffeeScript 1.4.0

define(function() {
  var GuessingPanel;
  return GuessingPanel = (function() {

    function GuessingPanel(params) {
      var k, v;
      for (k in params) {
        v = params[k];
        this[k] = v;
      }
      if (!(this.game != null)) {
        throw 'game was not set!';
      }
    }

    GuessingPanel.prototype.draw = function() {
      var ac, i, word, x, y, _i, _len, _ref, _results;
      ac = atom.context;
      i = 0;
      x = this.game.drawingArea.w + 16;
      y = this.game.drawingArea.h + 16;
      _ref = this.game.round.wordpile;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        word = _ref[_i];
        _results.push(ac.fillText(word, this.game.drawingArea.w + 16, this.game.drawingArea.h + 16));
      }
      return _results;
    };

    return GuessingPanel;

  })();
});
