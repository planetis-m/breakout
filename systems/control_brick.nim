import game_types, blueprints

const Query = {HasControlBrick, HasCollide, HasFade}

proc sysControlBrick*(game: var Game) =
   for i in 0 ..< MaxEntities:
      if game.world[i] * Query != {}:
         update(game, i)

proc update(game: var Game, entity: int) =
   template collide: untyped = game.collide[entity]
   template fade: untyped = game.fade[entity]

   if collide.collision.entity > -1:
      fade.step = 0.02

      if rand(1.0) > 0.98:
         discard game.getBall(float32(game.windowWidth / 2), float32(game.windowHeight / 2))
