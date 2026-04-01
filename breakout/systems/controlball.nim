import ".."/[blueprints, gametypes]

proc sysControlBall*(game: var Game) =
  for ball in mitems(game.balls):
    if ball.alive:
      var collide = addr game.colliders[ball.collide.int]
      var move = addr game.moves[ball.move.int]
      var transform = addr game.transforms[ball.transform.int]

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

      if collide.collision.hasHit:
        game.camera.shake.duration = 0.1

        if collide.collision.hit.x != 0:
          transform.translation.x += collide.collision.hit.x
          move.direction.x *= -1

        if collide.collision.hit.y != 0:
          transform.translation.y += collide.collision.hit.y
          move.direction.y *= -1

        game.createExplosion(transform.translation.x, transform.translation.y)

      transform.dirty = true
      game.createTrail(transform.translation.x, transform.translation.y)
