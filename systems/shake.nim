import ".." / [game_types, vmath], random

const Query = {HasTransform2d, HasShake}

proc update(game: var Game, entity: Entity) =
   template transform: untyped = game.transform[entity]
   template shake: untyped = game.shake[entity]

   if shake.duration > 0.0:
      shake.duration -= 0.01
      transform.translation.x = shake.strength - rand(shake.strength * 2.0)
      transform.translation.y = shake.strength - rand(shake.strength * 2.0)

      game.clearColor[0] = rand(255).uint8
      game.clearColor[1] = rand(255).uint8
      game.clearColor[2] = rand(255).uint8

      transform.dirty = true

      if shake.duration <= 0.0:
         shake.duration = 0.0
         transform.translation.x = 0.0
         transform.translation.y = 0.0
         game.clearColor[0] = 0
         game.clearColor[1] = 0
         game.clearColor[2] = 0

proc sysShake*(game: var Game) =
   for i in 0 ..< MaxEntities:
      if game.world[i] * Query == Query:
         update(game, Entity(i))
