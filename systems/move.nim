import ".." / [game_types, vmath, registry, storage]

const Query = {HasTransform2d, HasMove}

proc update(game: var Game, entity: Entity) =
   template transform: untyped = game.transform[entity.index]
   template move: untyped = game.move[entity.index]

   if move.direction.x != 0.0 or move.direction.y != 0.0:
      transform.translation.x += move.direction.x * move.speed
      transform.translation.y += move.direction.y * move.speed

      if entity.index == 192:
         echo "sysMove ", game.tickId, " ", isValid(entity, game.entities)
      game.dirty.add(entity)

proc sysMove*(game: var Game) =
   for entity, has in game.world.pairs:
      if has * Query == Query:
         update(game, entity)
