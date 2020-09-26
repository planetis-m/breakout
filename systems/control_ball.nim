import ".." / [game_types, vmath, blueprints, dsl, registry, storage]

const Query = {HasTransform2d, HasMove, HasCollide, HasControlBall}

proc update(game: var Game, entity: Entity) =
   template collide: untyped = game.collide[entity.index]
   template move: untyped = game.move[entity.index]
   template transform: untyped = game.transform[entity.index]

   if collide.min.x < 0.0:
      transform.translation.x = collide.size.x / 2.0
      move.direction.x *= -1.0

   if collide.max.x > game.windowWidth.float32:
      transform.translation.x = game.windowWidth.float32 - collide.size.x / 2.0
      move.direction.x *= -1.0

   if collide.min.y < 0.0:
      transform.translation.y = collide.size.y / 2.0
      move.direction.y *= -1.0

   if collide.max.y > game.windowHeight.float32:
      transform.translation.y = game.windowHeight.float32 - collide.size.y / 2.0
      move.direction.y *= -1.0

   if collide.collision.other != invalidId:
      let collision = collide.collision

      if HasShake in game.world[game.camera]:
         template cameraShake: untyped = game.shake
         cameraShake.duration = 0.1

      if collision.hit.x != 0.0:
         transform.translation.x += collision.hit.x
         move.direction.x *= -1.0

      if collision.hit.y != 0.0:
         transform.translation.y += collision.hit.y
         move.direction.y *= -1.0

      discard game.getExplosion(game.camera, transform.translation.x,
            transform.translation.y)

   let ballFade = game.addBlueprint:
      translation = transform.translation
      with:
         Draw2d(width: 20, height: 20, color: [0'u8, 255, 0, 255])
         Fade(step: 0.05)

proc sysControlBall*(game: var Game) =
   for entity, has in game.world.pairs:
      if has * Query == Query:
         update(game, entity)
