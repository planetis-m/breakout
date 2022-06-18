import ".."/[gametypes, sdlpriv]

template setInputState(val) =
  case event.key.keysym.scancode
  of SdlScancodeLeft, SdlScancodeA:
    game.inputState[Left] = val
  of SdlScancodeRight, SdlScancodeD:
    game.inputState[Right] = val
  else: discard

proc handleEvents*(game: var Game) =
  var event: Event
  while pollEvent(event):
    if event.kind == QuitEvent or (event.kind == KeyDown and
          event.key.keysym.scancode == SdlScancodeEscape):
      game.isRunning = false
    elif event.kind == KeyDown and not event.key.repeat:
      setInputState(true)
    elif event.kind == KeyUp and not event.key.repeat:
      setInputState(false)
