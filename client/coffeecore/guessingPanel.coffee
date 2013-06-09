define ->
  class GuessingPanel
    constructor : (params) ->
      @[k] = v for k, v of params
      if !@game? then throw 'game was not set!'
    
    
    
    draw : ->
      ac = atom.context
      i = 0
      x = @game.drawingArea.w+16
      y = @game.drawingArea.h+16
      (
        ac.fillText(word, @game.drawingArea.w+16, @game.drawingArea.h+16)
      ) for word in @game.round.wordpile