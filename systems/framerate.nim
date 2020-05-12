import game_types

proc sysFramerate*(game: var Game, delta: float32) =
   let window = game.canvas.window
   # let now = getTicks()

   # let diff = now - game.lastTime
   # let fps = 1000 / diff

   # game.lastTime = now
   window.setTitle("fps: " & int(1.0 / delta))
