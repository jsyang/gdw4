define ->
  class Word
    x         : 0
    y         : 0
    @W        : 240
    @H        : 60
    w         : 240
    h         : 40
    margin    : 16
    FONTSIZE  : 20
    
    value     : null
    
    chosen    : false
    correct   : false
    type      : 'predrawing' # predrawing or guessing
    index     : -1
    
    constructor : (params) ->
      @[k] = v for k, v of params
      #if !@game? then throw 'game was not set!'
      #@draw()
      
    setTextStyle : ->
      ac = atom.context
      ac.textBaseline = 'middle'
      ac.textAlign    = 'center'
      ac.font         = "bold #{@FONTSIZE}px sans-serif"
      if @type is 'predrawing'
        ac.fillStyle    = if @chosen then '#4EB581' else '#000'
      else
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
      ac.fillStyle    = '#eee'
      ac.fillRect(@x,@y,@w,@h)
      ac.strokeRect(@x+1,@y+1,@w-2,@h-2)
      
      @setTextStyle()
      keyToPress = @index+1
      if keyToPress > 9
        keyToPress = 0
      ac.fillText("[#{@index}] #{@value}", @x+(@w>>1), @y+(@h>>1))
      @