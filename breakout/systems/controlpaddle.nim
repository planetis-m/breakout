import ".."/gamecore

proc sysControlPaddle*(game: var Game) =
  if game.paddle.node == NoNodeIdx:
    return

  template move: untyped = game.moves[game.paddle.move.int]
  move.direction.x = 0
  if game.inputState[Left]:
    move.direction.x -= 1
  if game.inputState[Right]:
    move.direction.x += 1
