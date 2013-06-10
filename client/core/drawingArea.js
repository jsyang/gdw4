// Generated by CoffeeScript 1.4.0

define(function() {
  var DrawingArea;
  return DrawingArea = (function() {

    DrawingArea.prototype.x = 0;

    DrawingArea.prototype.y = 0;

    DrawingArea.prototype.w = 600;

    DrawingArea.prototype.h = 400;

    DrawingArea.prototype.margin = 16;

    DrawingArea.prototype.chosen = [];

    function DrawingArea(params) {
      var k, v;
      for (k in params) {
        v = params[k];
        this[k] = v;
      }
      this.resize().clear();
    }

    DrawingArea.prototype.setLineStyle = function() {
      var ac;
      ac = atom.context;
      ac.lineCap = 'round';
      ac.lineWidth = 4.0;
      return ac.strokeStyle = '#000';
    };

    DrawingArea.prototype.draw = function() {
      var ac, line, _i, _len, _ref;
      ac = atom.context;
      ac.clearRect(this.x, this.y, this.w, this.h);
      ac.fillStyle = '#ddd';
      ac.fillRect(this.x, this.y, this.w, this.h);
      ac.font = '12px sans-serif';
      ac.textBaseline = 'top';
      ac.textAlign = 'left';
      ac.fillStyle = '#000';
      if (this.game.network.role === 'd') {
        ac.fillText("Draw '" + (this.chosen.join(' ')) + "' here! ", this.x, this.y);
      }
      _ref = this.drawing;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        line = _ref[_i];
        this.drawLine(line);
      }
      return this;
    };

    DrawingArea.prototype.drawLine = function(line) {
      var ac;
      ac = atom.context;
      this.setLineStyle();
      ac.beginPath();
      ac.moveTo(line.x1, line.y1);
      ac.lineTo(line.x2, line.y2);
      ac.stroke();
      return this;
    };

    DrawingArea.prototype.add = function(line) {
      this.drawing.push(line);
      this.drawLine(line);
      return this.game.network.socket.emit('addLine', line);
    };

    DrawingArea.prototype.resize = function() {
      this.x = this.margin;
      this.y = this.margin;
      return this;
    };

    DrawingArea.prototype.clear = function() {
      this.drawing = [];
      return this;
    };

    return DrawingArea;

  })();
});
