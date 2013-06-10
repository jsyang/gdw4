// Generated by CoffeeScript 1.4.0

define(function() {
  var Chat;
  return Chat = (function() {

    Chat.prototype.w = 400;

    Chat.prototype.h = 400;

    Chat.prototype.margin = 16;

    Chat.prototype.FONTSIZE = 12;

    Chat.prototype.inputEl = null;

    Chat.prototype.onKeyPress = function(e) {
      switch (e.which) {
        case 13:
          this.add({
            name: this.game.network.name,
            msg: e.target.value
          });
          e.target.value = '';
      }
    };

    Chat.prototype.createChatInput = function() {
      var css, k, style, v,
        _this = this;
      this.inputEl = document.createElement('input');
      this.inputEl = $$.extend(this.inputEl, {
        onkeypress: function(e) {
          return _this.onKeyPress(e);
        },
        type: 'text'
      });
      style = this.inputEl.style;
      css = {
        position: 'absolute',
        left: this.x,
        top: this.h - this.FONTSIZE,
        height: this.FONTSIZE + this.margin,
        width: this.w,
        zIndex: 2
      };
      for (k in css) {
        v = css[k];
        style[k] = v;
      }
      document.body.appendChild(this.inputEl);
      return this;
    };

    function Chat(params) {
      var k, v;
      for (k in params) {
        v = params[k];
        this[k] = v;
      }
      if (!(this.game != null)) {
        throw 'game was not set!';
      }
      this.resize().createChatInput().draw();
    }

    Chat.prototype.add = function(msgObj) {
      if (this.messages.length + 1 > this.MAXLINES) {
        this.messages.shift();
      }
      this.messages.push(msgObj);
      return this.draw();
    };

    Chat.prototype.messages = [
      {
        name: 'Jim',
        msg: 'Hi there!'
      }, {
        name: 'Jim',
        msg: 'This is a test!'
      }
    ];

    Chat.prototype.MAXLINES = 20;

    Chat.prototype.MAXNAMELENGTH = 16;

    Chat.prototype.resize = function() {
      this.x = this.game.drawingArea.x + this.game.drawingArea.w + this.margin;
      this.w = atom.width - this.game.drawingArea.x - this.game.drawingArea.w - this.margin * 2;
      this.MAXLINES = ((this.h - (this.FONTSIZE + this.margin * 2)) / this.FONTSIZE) >> 0;
      if (this.inputEl != null) {
        this.inputEl.style.width = this.w;
      }
      return this;
    };

    Chat.prototype.draw = function() {
      var ac, m, maxW, name, x, y, _i, _len, _ref;
      ac = atom.context;
      x = this.x;
      y = this.margin;
      maxW = this.w - this.margin * 2;
      ac.clearRect(x, y, this.w, this.h);
      ac.lineWidth = 1;
      ac.strokeStyle = '#888';
      ac.fillStyle = '#000';
      ac.font = this.FONTSIZE + 'px sans-serif';
      ac.textAlign = 'left';
      ac.textBaseline = 'top';
      ac.strokeRect(x, y, this.w, this.h);
      _ref = this.messages;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        m = _ref[_i];
        name = m.name.length > this.MAXNAMELENGTH ? m.name.substr(0, this.MAXNAMELENGTH - 3) + '...' : m.name;
        ac.fillText("[" + name + "] " + m.msg, x, y, maxW);
        y += 12;
      }
      return this;
    };

    return Chat;

  })();
});
