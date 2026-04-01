import ".."/gametypes

proc sysControlPaddle*(game: var Game) =
  if game.paddle == NoActorIdx:
    return

  let moveIdx = game.actors[game.paddle.int].move
  template move: untyped = game.moves[moveIdx]
  move.direction.x = 0

  if game.inputState[Left]:
    move.direction.x -= 1

  if game.inputState[Right]:
    move.direction.x += 1
