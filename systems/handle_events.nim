import ".." / [game_types, sdl_private]

proc handleEvents*(game: var Game) =
   for event in game.eventPump.poll():
      if event.kind == QuitEvent or (event.kind == KeyDown and
            event.scancode == Escape):
         game.isRunning = false
         return
      elif event.kind == KeyDown and not event.repeat:
         case event.scancode
         of ArrowLeft, KeyA:
            game.inputState[ArrowLeft] = true
         of ArrowRight, KeyD:
            game.inputState[ArrowRight] = true
      elif event.kind == KeyUp and not event.repeat:
         case event.scancode
         of ArrowLeft, KeyA:
            game.inputState[ArrowLeft] = false
         of ArrowRight, KeyD:
            game.inputState[ArrowRight] = false
