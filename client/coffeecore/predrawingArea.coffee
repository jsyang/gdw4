define [ 'core/word' ], (Word) ->
  class PredrawingArea
    x         : 0
    y         : 0
    w         : 600
    h         : 400
    margin    : 16
    FONTSIZE  : 20
    
    words   : []
    
    chosen  : []
    
    button :
      ok :
        text  : 'OK'
        x     : 0
        y     : 0
        w     : 60
        h     : 40
        color : '#ACFAD3'
        
      reset :
        text  : 'Reset'
        x     : 0
        y     : 0
        w     : 80
        h     : 40
        color : '#FA8CB1'
        
    constructor : (params) ->
      @[k] = v for k, v of params
      if !@game? then throw 'game was not set!'
      @resize()
    
    add : (words) ->
      @words = ( new Word(wordParams) for wordParams in words[0...10])
      @arrangeWords()
      @draw()
    
    setTextStyle : ->
      ac = atom.context
      ac.textBaseline = 'middle'
      ac.font         = "bold #{@FONTSIZE}px sans-serif"
      ac.fillStyle    = '#000'
      @
    
    arrangeWords : ->
      wordW = @words[0].w
      wordH = @words[0].h
      
      i = 0
      # Column 1
      x = @x + (((@w>>1) - wordW)>>1)
      y = @y + 2*@margin + @FONTSIZE 
      (
        w.x = x
        w.y = y
        w.index = i
        y += wordH + @margin
        i++
      ) for w in @words[0...5]
      
      # Column 2
      x = @x + (@w>>1) + (((@w>>1) - wordW)>>1)
      y = @y + 2*@margin + @FONTSIZE 
      (
        w.x = x
        w.y = y
        w.index = i
        y += wordH + @margin
        i++
      ) for w in @words[5...10]
      @
    
    clear : -> atom.context.clearRect(@x, @y, @w, @h)
    
    draw : ->
      ac = atom.context
      @clear()
      
      ac.fillStyle = '#eee'
      ac.fillRect(@x, @y, @w, @h)
      
      @setTextStyle()
      
      if @game.network.role is 'd'
        ac.textAlign  = 'left'
        # Maybe put a timer here for drawer inactivity
        # If you haven't chosen words by then, the next player gets to go.
        ac.fillText("Pick two words to draw :", @x+@margin, @y+(@FONTSIZE>>1)+@margin)
        
        w.draw() for w in @words
        
        wordH         = @words[0].h + @words[0].margin
        word1         = @chosen[0] or ''
        word2         = @chosen[1] or ''
        ac.textAlign  = 'left'
        ac.fillStyle  = '#000'
        if word1.length + word2.length is 0
          ac.fillText("No words selected.", @x+@margin, @y+(@FONTSIZE>>1)+@margin+wordH*6)
        else 
          ac.fillText("You'll be drawing '#{word1}#{' '+word2}'.", @x+@margin, @y+(@FONTSIZE>>1)+@margin+wordH*6)
        
        x = @x + @w
        y = @y+@FONTSIZE+wordH*6 
        (
          x -= @margin + b.w
          b.x = x
          b.y = y-(b.h>>1)
          ac.fillStyle = b.color
          ac.fillRect(b.x, b.y, b.w, b.h)
          ac.fillStyle = '#000'
          ac.textAlign  = 'center'
          ac.fillText(b.text, x+(b.w>>1), y)
        ) for b in [@button.reset, @button.ok]
        
      else
        ac.textAlign  = 'center'
        ac.fillText("Waiting on #{@game.network.whoseTurn} to begin...", @x+(@w>>1), @y+(@h>>1))
      
      @
      
    resize : ->
      @x = @margin
      @y = @margin
      @