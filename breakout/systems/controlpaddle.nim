import ".." / [gametypes, heaparray, vmath, registry, storage]

const Query = {HasMove, HasControlPaddle}

proc update(game: var Game, entity: Entity) =
  template move: untyped = game.world.move[entity.index]

  move.direction.x = 0.0

  if game.inputState[Left]:
    move.direction.x -= 1.0

  if game.inputState[Right]:
    move.direction.x += 1.0

proc sysControlPaddle*(game: var Game) =
  for entity, has in game.world.signature.pairs:
    if has * Query == Query:
      update(game, entity)
