import ".."/[gametypes, sdlpriv]

proc handleEvents*(game: var Game) =
  var event: Event
  while pollEvent(event):
    if event.kind == QuitEvent or (event.kind == KeyDown and
          event.key.keysym.scancode == SdlScancodeEscape):
      game.isRunning = false
    elif event.kind == KeyDown and not event.key.repeat:
      case event.key.keysym.scancode
      of SdlScancodeLeft, SdlScancodeA:
        game.inputState[Left] = true
      of SdlScancodeRight, SdlScancodeD:
        game.inputState[Right] = true
      else: discard
    elif event.kind == KeyUp and not event.key.repeat:
      case event.key.keysym.scancode
      of SdlScancodeLeft, SdlScancodeA:
        game.inputState[Left] = false
      of SdlScancodeRight, SdlScancodeD:
        game.inputState[Right] = false
      else: discard
