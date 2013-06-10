define ->
  class DrawingArea
    x : 16
    y : 16
    w : 600
    h : 400
    
    constructor : (params) ->
      @[k] = v for k, v of params
      @drawing = []
      @draw()
    
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
      ac.fillText('Draw here!',@x,@y)
      
      @drawLine(line) for line in @drawing
      return
    
    drawLine : (line) ->
      ac = atom.context
      @setLineStyle()
      ac.beginPath()
      ac.moveTo(line.x1, line.y1)
      ac.lineTo(line.x2, line.y2)
      ac.stroke()
      return
    
    add : (line) ->
      @drawing.push(line)
      @drawLine(line)
      @game.network.socket.emit('addLine', line)
      
    clear : ->
      @drawing = []
      