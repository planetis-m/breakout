import ".."/gametypes

proc sysControlPaddle*(game: var Game) =
  if not game.paddle.active:
    return

  game.paddle.move.direction.x = 0
  if game.inputState[Left]:
    game.paddle.move.direction.x -= 1
  if game.inputState[Right]:
    game.paddle.move.direction.x += 1
