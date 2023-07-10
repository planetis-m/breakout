import ".."/[gametypes, heaparrays, vmath, blueprints, builddsl, slottables]

const Query = {HasTransform2d, HasMove, HasCollide, HasControlBall}

proc update(game: var Game, entity: Entity) =
  template collide: untyped = game.world.collide[entity.idx]
  template move: untyped = game.world.move[entity.idx]
  template transform: untyped = game.world.transform[entity.idx]

  if collide.min.x < 0:
    transform.translation.x = collide.size.x / 2
    move.direction.x *= -1

  if collide.max.x > game.windowWidth.float32:
    transform.translation.x = game.windowWidth.float32 - collide.size.x / 2
    move.direction.x *= -1

  if collide.min.y < 0:
    transform.translation.y = collide.size.y / 2
    move.direction.y *= -1

  if collide.max.y > game.windowHeight.float32:
    transform.translation.y = game.windowHeight.float32 - collide.size.y / 2
    move.direction.y *= -1

  if collide.collision.other != InvalidId:
    let collision = collide.collision
    if HasShake in game.world.signature[game.camera]:
      template cameraShake: untyped = game.world.shake[]
      cameraShake.duration = 0.1

    if collision.hit.x != 0:
      transform.translation.x += collision.hit.x
      move.direction.x *= -1

    if collision.hit.y != 0:
      transform.translation.y += collision.hit.y
      move.direction.y *= -1

    discard game.world.createExplosion(game.camera, transform.translation.x,
        transform.translation.y)

  let ballFade = game.world.build(blueprint):
    with:
      Transform2d(translation: transform.translation, parent: game.camera)
      Draw2d(width: 20, height: 20, color: [0'u8, 255, 0, 255])
      Fade(step: 0.05)

proc sysControlBall*(game: var Game) =
  for entity, signature in game.world.signature.pairs:
    if Query <= signature:
      update(game, entity)
