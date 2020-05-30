import game_types, strformat

proc sysFramerate*(game: var Game; intrpl: float32) =
   let window = game.canvas.window

   #game.frameCount.inc
   let fps = 1.0 / (intrpl * 1.0e-9)

   window.setTitle(&"fps: {fps:.1}, frames: {frameCount}")
