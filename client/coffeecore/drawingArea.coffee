define ->
  class DrawingArea
    x : 0
    y : 0
    w : 600
    h : 400
    
    margin : 16
    
    chosen : []
    
    constructor : (params) ->
      @[k] = v for k, v of params
      @resize().clear()
      #.draw()
    
    setLineStyle : ->
      ac = atom.context
      ac.lineCap      = 'round'
      ac.lineWidth    = 4.0
      ac.strokeStyle  = '#000'
    
    draw : ->
      ac = atom.context
      ac.clearRect(@x, @y, @w, @h)
      
      ac.fillStyle = '#ddd'
      ac.fillRect(@x,@y,@w,@h)
      
      ac.font         = '12px sans-serif'
      ac.textBaseline = 'top'
      ac.textAlign    = 'left'
      ac.fillStyle    = '#000'
      if @game.network.role is 'd'
        ac.fillText("Draw '#{@chosen.join(' ')}' here! ",@x,@y)
        
      # instead of showing it here, indicate it in the player cards?
      #else
      #  ac.fillText("#{@game.network.whoseTurn} is drawing.",@x,@y)
      
      @drawLine(line) for line in @drawing
      @
    
    drawLine : (line) ->
      ac = atom.context
      @setLineStyle()
      ac.beginPath()
      ac.moveTo(line.x1, line.y1)
      ac.lineTo(line.x2, line.y2)
      ac.stroke()
      @
    
    add : (line) ->
      @drawing.push(line)
      @drawLine(line)
      @game.network.socket.emit('addLine', line)
      
    resize : ->
      @x = @margin
      @y = @margin
      @
    
    clear : ->
      @drawing = []
      @