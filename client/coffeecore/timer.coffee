define ->
  class Timer
    x         : 0
    y         : 0
    margin    : 16
    FONTSIZE  : 16
    
    FACTORMINUTES : 0.000016666
    FACTORSECONDS : 0.001
    
    constructor : (params) ->
      @[k] = v for k, v of params
      if !@game? then throw 'game was not set!'
      
      @resize().draw()
    
    setTextStyle : ->
      ac = atom.context
      ac.textBaseline = 'middle'
      ac.textAlign    = 'center'
      ac.font         = @FONTSIZE+'px sans-serif'
      ac.fillStyle    = '#000'
      return
    
    draw : ->
      ac = atom.context
      ac.clearRect(@x, @y, @w, @h)
      
      ac.fillStyle = '#FCFFD9'
      ac.fillRect(@x, @y, @w, @h)
      
      @setTextStyle()
      time = @game.timeLeft()
      minutes = (time * @FACTORMINUTES)>>0
      seconds = (time * @FACTORSECONDS)>>0
      ac.fillText("#{minutes} min #{seconds} seconds left", @x+(@w>>1), @y+(@h>>1))
      @
      
    resize : ->
      @x = @margin
      @y = @game.drawingArea.y+@game.drawingArea.h+@margin
      @w = atom.width - @margin*2
      @h = @FONTSIZE + @margin
      @
    