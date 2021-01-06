import ".."/[gametypes, heaparrays, vmath, builddsl, slottables]

const Query = {HasTransform2d, HasMove}

proc update(game: var Game, entity: Entity) =
  template transform: untyped = game.world.transform[entity.idx]
  template move: untyped = game.world.move[entity.idx]

  if move.direction.x != 0.0 or move.direction.y != 0.0:
    transform.translation.x += move.direction.x * move.speed
    transform.translation.y += move.direction.y * move.speed

    game.world.mixDirty(entity)

proc sysMove*(game: var Game) =
  for entity, signature in game.world.signature.pairs:
    if signature * Query == Query:
      update(game, entity)
