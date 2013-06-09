define ['core/player'], (Player) ->
  class Guesser extends Player
    role : 'guesser'
    
    @W : 120
    @H : 200
    
    w : 120
    h : 200
    
    guessWord : (word) ->
      wordObj = {
        word
        status : 'correct'
      }
      
      if @words?
        @words.push(wordObj)
      else
        @words = [wordObj]
    
    marginY : 4
    
    draw : (x,y) ->
      ac = atom.context
      ac.lineWidth = 1.0
      ac.fillStyle = '#000'
      ac.strokeRect(x,y,@w,@h)
      
      fontSize = 12
      ac.textBaseline = 'top'
      ac.textAlign    = 'center'
      ac.font         = fontSize + 'px sans-serif'
      ac.fillText(@name, x+(@w>>1), y+@marginY)
    
      margin = 4
      _y = y+(@h>>1)
      height = 20
      #ac.strokeRect(x,y+(@h>>1)-margin,@w,12+margin*2)
      ac.textAlign    = 'center'
      (
        ac.fillStyle = if w.status is 'incorrect' then '#F28F8F' else '8FF2A1'
        ac.fillRect(x, _y-margin, @w, fontSize+margin*2)
        ac.fillStyle = '#000'
        ac.fillText(w.word, x+(@w>>1), _y+(height>>1)-(fontSize))
        _y += height
      ) for w in @words unless !@words?