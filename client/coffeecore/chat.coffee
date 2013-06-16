define ->
  class Chat
  
    w         : 400
    h         : 400
    margin    : 16
  
    FONTSIZE  : 12
    inputEl   : null
  
    onKeyPress : (e) ->
      switch e.which
        when 13 # ENTER
          # todo: actually hook this up to network
          #@add(chatmsg)
          @game.network.send_chatmsg(e.target.value)
          e.target.value = ''
          #e.target.blur()
        
      return
  
    createChatInput : ->
      @inputEl = document.createElement('input')
      @inputEl = $$.extend( @inputEl, {
        onkeypress  : (e) => @onKeyPress(e)
        type        : 'text'
      })
      
      style = @inputEl.style
      css =
        position  : 'absolute'
        left      : @x
        top       : @h - @FONTSIZE
        height    : @FONTSIZE+@margin
        width     : @w
        zIndex    : 2
      
      style[k] = v for k,v of css
      document.body.appendChild(@inputEl)
      @
  
    constructor : (params) ->
      @[k] = v for k, v of params
      if !@game? then throw 'game was not set!'
      
      @resize().createChatInput().draw()
      
    add : (msgObj) ->
      msgExcess = @messages.length - @MAXLINES
      if msgExcess > 0
        @messages = @messages[msgExcess..]
      @messages.push(msgObj)
      @draw()
  
    messages : [
      {
        name  : 'Jim'
        msg   : 'Hi there!'
      },
      {
        name  : 'Jim'
        msg   : 'This is a test!'
      },
    ]
    
    MAXLINES      : 20
    MAXNAMELENGTH : 16
    
    resize : ->
      @x = @game.drawingArea.x+@game.drawingArea.w+@margin
      @w = atom.width-@game.drawingArea.x-@game.drawingArea.w-@margin*2
      @MAXLINES = ((@h - (@FONTSIZE+@margin*2)) / @FONTSIZE)>>0
      if @inputEl?
        @inputEl.style.width = @w
      @
    
    draw : ->
      ac = atom.context
      
      x     = @x
      y     = @margin
      maxW  = @w-@margin*2
      
      ac.clearRect(x,y,@w,@h)
      
      ac.lineWidth    = 1
      ac.strokeStyle  = '#888'
      ac.fillStyle    = '#000'
      ac.textAlign    = 'left'
      ac.textBaseline = 'top'
      
      ac.strokeRect(x, y, @w, @h)
      (
        name = if m.name.length > @MAXNAMELENGTH then m.name.substr(0,@MAXNAMELENGTH-3)+'...' else m.name
        name = "[#{name}] "
        # todo : split long lines, maybe we can do this in add()?
        
        ac.font = "bold #{@FONTSIZE}px sans-serif"
        ac.fillText(name, x, y, maxW)
        
        msgX    = x + ac.measureText(name).width
        ac.font = "#{@FONTSIZE}px sans-serif"
        ac.fillText(m.msg, msgX, y, maxW)
        
        y += 12
      ) for m in @messages
      
      @
    