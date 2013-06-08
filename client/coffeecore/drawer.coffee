define ['core/player'], (Player) ->
  class Drawer extends Player
    role      : 'drawer'
    timeLeft  : 60  # seconds
    drawing   : []