import ".."/[gamecore, raylib]

proc handleEvents*(game: var Game) =
  pollInput()
  if windowShouldClose() or keyPressed(KEY_ESCAPE):
    game.isRunning = false

  game.inputState[Left] = keyDown(KEY_LEFT) or keyDown(KEY_A)
  game.inputState[Right] = keyDown(KEY_RIGHT) or keyDown(KEY_D)
