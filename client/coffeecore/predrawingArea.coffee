define ->
  class PredrawingArea
    x         : 0
    y         : 0
    w         : 600
    h         : 400
    margin    : 16
    FONTSIZE  : 20
    
    words : []
      
    constructor : (params) ->
      @[k] = v for k, v of params
      if !@game? then throw 'game was not set!'
      @resize()
    
    addWord : (word) ->
      words.push(word)
      @
    
    setTextStyle : ->
      ac = atom.context
      ac.textBaseline = 'middle'
      ac.textAlign    = 'center'
      ac.font         = "bold #{@FONTSIZE}px sans-serif"
      ac.fillStyle    = '#000'
      @
    
    draw : ->
      ac = atom.context
      ac.clearRect(@x, @y, @w, @h)
      
      ac.fillStyle = '#eee'
      ac.fillRect(@x, @y, @w, @h)
      
      @setTextStyle()
      if @game.network.role is 'd'
        ac.fillText("Choose 2 words to draw", @x+(@w>>1), @y+(@FONTSIZE>>1)+@margin)
      else
        ac.fillText("Waiting on #{@game.network.whoseTurn} to draw...", @x+(@w>>1), @y+(@h>>1))
      @
      
    resize : ->
      @x = @margin
      @y = @margin
      @