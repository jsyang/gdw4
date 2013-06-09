define ['core/player'], (Player) ->
  class Guesser extends Player
    role : 'guesser'
    
    @W : 120
    @H : 200
    
    w : 120
    h : 200
    
    guessWord : (word) ->
      if @words?
        @words.push(word)
      else
        @words = [word]
    
    marginY : 4
    
    draw : (x,y) ->
      ac = atom.context
      ac.lineWidth = 1.0
      ac.fillStyle = '#000'
      ac.strokeRect(x,y,@w,@h)
      
      ac.textBaseline = 'top'
      ac.textAlign = 'center'
      ac.fillText(@name, x+(@w>>1), y+@marginY)
      
      