import game_types, vmath, blueprints, dsl

const Query = {HasTransform2d, HasMove, HasControlBall}

proc sysControlBall*(game: var Game) =
   for i in 0 ..< MaxEntities:
      if game.world[i] * Query != {}:
         update(game, Entity(i))

proc update(game: var Game, entity: Entity) =
   template transform: untyped = game.transform[entity]
   template move: untyped = game.move[entity]
   template control: untyped = game.controlBall[entity]

   if transform.translation.x < 0.0:
      transform.translation.x = 0.0
      control.direction.x *= -1.0

   if transform.translation.x > game.windowWidth.float32:
      transform.translation.x = game.windowWidth.float32
      control.direction.x *= -1.0

   if transform.translation.y < 0.0:
      transform.translation.y = 0.0
      control.direction.y *= -1.0

   if transform.translation.y > game.windowHeight.float32:
      transform.translation.y = game.windowHeight.float32
      control.direction.y *= -1.0

   if HasCollide in game.world[entity]:
      template collide = game.collide[entity]
      if collide.collision.entity > -1:
         let collision = collide.collision

         if HasShake in game.world[game.camera]:
            template cameraShake: untyped = game.shake[game.camera]
            cameraShake.duration = 0.2

         if collision.hit.x != 0.0:
            transform.translation.x += collision.hit.x
            control.direction.x *= -1.0

         if collision.hit.y != 0.0:
            transform.translation.y += collision.hit.y
            control.direction.y *= -1.0

         discard game.getExplosion(x, y)

   move.direction.x = control.direction.x
   move.direction.y = control.direction.y

   let x = transform.translation.x
   let y = transform.translation.y

   let ballFade = game.addBlueprint:
      translation = Vec2(x: x, y: y)
      with:
         Draw2d(witdth: 20, height: 20, color: [0'u8, 255, 0, 255])
         Fade(step: 0.05)
