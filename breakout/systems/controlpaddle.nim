import ".."/[gametypes, heaparrays, vmath, slottables]

const Query = {HasMove, HasControlPaddle}

proc update(game: var Game, entity: Entity) =
  template move: untyped = game.world.move[entity.idx]

  move.direction.x = 0

  if game.inputState[Left]:
    move.direction.x -= 1

  if game.inputState[Right]:
    move.direction.x += 1

proc sysControlPaddle*(game: var Game) =
  for entity, signature in game.world.signature.pairs:
    if Query <= signature:
      update(game, entity)
