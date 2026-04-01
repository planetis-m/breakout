import ".."/gametypes

proc sysControlPaddle*(game: var Game) =
  let moveIdx = game.paddle.move
  var move = addr game.moves[moveIdx.int]
  move.direction.x = 0

  if game.inputState[Left]:
    move.direction.x -= 1

  if game.inputState[Right]:
    move.direction.x += 1
