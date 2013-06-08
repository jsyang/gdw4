define ->
  class DrawingArea
    x : 16
    y : 16
    w : 600
    h : 400
    
    constructor : (params) ->
      @[k] = v for k, v of params
      @drawing = []
    
    draw : ->
      ac = atom.context
      ac.fillStyle = '#ddd'
      ac.fillRect(@x,@y,@w,@h)
      ac.font = '12px sans-serif'
      ac.fillStyle = '#000'
      ac.textBaseline = 'top'
      ac.fillText('Draw here!',@x,@y)
      ac.lineCap = 'round'
      ac.lineWidth = 4.0
      (
        ac.beginPath()
        ac.moveTo(line.x1, line.y1)
        ac.lineTo(line.x2, line.y2)
        ac.stroke()
      ) for line in @drawing
      
      
      
    clear : ->
      @drawing = []
      