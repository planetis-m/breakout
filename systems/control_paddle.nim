import game_types, vmath

const Query = {HasMove, HasControlPaddle}

proc sysControlPaddle*(game: var Game) =
   for i in 0 ..< MaxEntities:
      if game.world[i] * Query != {}:
         update(game, Entity(i))

proc update(game: var Game, entity: Entity) =
   template move: untyped = game.move[entity]

   move.direction.x = 0.0

   if game.inputState[Left]:
      move.direction.x -= 1.0

   if game.inputState[Right]:
      move.direction.x += 1.0
