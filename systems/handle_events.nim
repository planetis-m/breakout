import ".." / [game_types, sdl_private, serialize]

proc handleEvents*(game: var Game) =
   var event: Event
   while pollEvent(event):
      if event.kind == QuitEvent or (event.kind == KeyDown and
            event.key.keysym.scancode == SDL_SCANCODE_ESCAPE):
         game.isRunning = false
      elif event.kind == KeyDown and not event.key.repeat:
         case event.key.keysym.scancode
         of SDL_SCANCODE_LEFT, SDL_SCANCODE_A:
            game.inputState[Left] = true
         of SDL_SCANCODE_RIGHT, SDL_SCANCODE_D:
            game.inputState[Right] = true
         of SDL_SCANCODE_S:
            save(game)
         of SDL_SCANCODE_L:
            load(game)
         else: discard
      elif event.kind == KeyUp and not event.key.repeat:
         case event.key.keysym.scancode
         of SDL_SCANCODE_LEFT, SDL_SCANCODE_A:
            game.inputState[Left] = false
         of SDL_SCANCODE_RIGHT, SDL_SCANCODE_D:
            game.inputState[Right] = false
         else: discard
