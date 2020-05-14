import game_types

proc sysHandleInput(self: var Game) =
   for event in self.eventPump.poll():
      if event.kind == QuitEvent or (event.kind == KeyDown and
            event.scancode == Escape):
         self.running = false
         return
      elif event.kind == KeyDown and not event.repeat:
         case event.scancode
         of ArrowLeft, KeyA:
            self.inputState[ArrowLeft] = true
         of ArrowRight, KeyD:
            self.inputState[ArrowRight] = true
      elif event.kind == KeyUp and not event.repeat:
         case event.scancode
         of ArrowLeft, KeyA:
            self.inputState[ArrowLeft] = false
         of ArrowRight, KeyD:
            self.inputState[ArrowRight] = false
