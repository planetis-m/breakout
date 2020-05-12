import game_types, vmath

const Query = {HasTransform2d, HasMove}

proc sysMove*(game: var Game) =
   for i in 0 ..< MaxEntities:
      if game.world[i] * Query != {}:
         update(game, i)

proc update(game: var Game, entity: int) =
   template transform: untyped = game.transform[entity]
   template move: untyped = game.move[entity]

   if move.direction.x != 0.0 or move.direction.y != 0.0:
      transform.translation.x += move.direction.x * move.speed
      transform.translation.y += move.direction.y * move.speed

      transform.dirty = true
