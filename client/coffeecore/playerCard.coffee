define ->
  class PlayerCard
    
    @W        : 160
    @H        : 120
    @MARGIN   : 16
    w         : 160
    h         : 120
    margin    : 16
    x         : 0
    y         : 0
    FONTSIZE  : 14

    wordsGuessed  : null
    name          : null
    
    constructor : (params) ->
      @[k] = v for k, v of params
      if !@game? then throw 'game was not set!'
      
      @resize().draw()
    
    reorganize : ->
      i   = @game.playerCards.indexOf(@)
      @x  = @margin + i*(@w+@margin)
      @
    
    resize : ->
      @y = @game.drawingArea.y + @game.drawingArea.h + @margin + @game.timer.h + @margin
      @
      
    setTextStyle : ->
      ac = atom.context
      ac.textBaseline = 'middle'
      ac.textAlign    = 'center'
      ac.font         = "bold #{@FONTSIZE}px sans-serif"
      ac.fillStyle    = '#000'
      @
    
    clear : ->
      ac = atom.context
      ac.clearRect(@x,@y,@w,@h)
      @
    
    draw : ->
      ac = atom.context
      @clear()
      
      ac.strokeStyle  = '#000'
      ac.lineWidth    = 1
      ac.fillStyle    = '#efeffe'
      ac.fillRect(@x,@y,@w,@h)
      ac.strokeRect(@x+1,@y+1,@w-2,@h-2)
      
      @setTextStyle()
      ac.fillText(@name, @x+(@w>>1), @y+(@h>>1))
      @