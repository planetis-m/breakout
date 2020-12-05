import ".." / [game_types, vmath, dsl, registry, storage]

const Query = {HasTransform2d, HasMove}

proc update(game: var Game, entity: Entity) =
   template transform: untyped = game.world.transform[entity.index]
   template move: untyped = game.world.move[entity.index]

   if move.direction.x != 0.0 or move.direction.y != 0.0:
      transform.translation.x += move.direction.x * move.speed
      transform.translation.y += move.direction.y * move.speed

      game.world.mixDirty(entity)

proc sysMove*(game: var Game) =
   for entity, has in game.world.signature.pairs:
      if has * Query == Query:
         update(game, entity)
