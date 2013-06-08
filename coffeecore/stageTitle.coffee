define ->
  class StageTitle    
    SPRITENAME : null
    GFX :
      'roundover' :
        W   : 300
        H   : 100
        W_2 : 150
        H_2 : 50
        LIFETIME : 300
    
    draw : ->
      ac = atom.context
      
      # Fadeout
      if @lifetime < 40 then ac.globalAlpha = @lifetime * 0.025
        
      ac.drawImage(
        atom.gfx[@SPRITENAME],
        (atom.width>>1)-@GFX[@SPRITENAME].W_2,
        (atom.height>>1)-@GFX[@SPRITENAME].H_2
      )
      
      if @lifetime < 40 then ac.globalAlpha = 1
        
      return
      
    remove : ->
      @move = null
      @game = null
    
    move : ->
      if @lifetime > 0
        @lifetime--
      else
        @remove()
      return
      
    constructor : (params) ->
      @[k] = v for k, v of params
      @lifetime = @GFX[@SPRITENAME].LIFETIME