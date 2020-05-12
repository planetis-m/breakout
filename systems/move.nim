import game_types, vmath

const Query = {HasTransform2d, HasMove}

proc sysMove*(game: var Game, delta: float32) =
   for i in 0 ..< MaxEntities:
      if game.world[i] * Query != {}:
         update(game, i, delta)

proc update(game: var Game, entity: int, delta: float32) =
   template transform: untyped = game.transform[entity]
   template move: untyped = game.move[entity]

   if move.direction.x != 0.0 or move.direction.y != 0.0:
      transform.translation.x += move.direction.x * move.speed * delta
      transform.translation.y += move.direction.y * move.speed * delta

      transform.dirty = true
