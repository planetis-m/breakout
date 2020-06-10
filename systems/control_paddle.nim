import ".." / [game_types, vmath]

const Query = {HasMove, HasControlPaddle}

proc update(game: var Game, entity: Entity) =
   template move: untyped = game.move[entity.index]

   move.direction.x = 0.0

   if game.inputState[Left]:
      move.direction.x -= 1.0

   if game.inputState[Right]:
      move.direction.x += 1.0

proc sysControlPaddle*(game: var Game) =
   for i in 0 ..< MaxEntities:
      let entity = Entity(i)
      if game.world[entity] * Query == Query:
         update(game, entity)
