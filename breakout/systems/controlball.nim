import ".."/[blueprints, gametypes]

proc sysControlBall*(game: var Game) =
  let actorCount = game.actors.len
  for i in 0..<actorCount:
    template ball: untyped = game.actors[i]
    if ball.kind == BallKind and ball.alive:
      template collide: untyped = game.colliders[ball.collide]
      template move: untyped = game.moves[ball.move]
      template transform: untyped = game.transforms[ball.transform]

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

      if Hit in collide.collision.flags:
        game.camera.shake.duration = 0.1

        if collide.collision.hit.x != 0:
          transform.translation.x += collide.collision.hit.x
          move.direction.x *= -1

        if collide.collision.hit.y != 0:
          transform.translation.y += collide.collision.hit.y
          move.direction.y *= -1

        game.createExplosion(transform.translation.x, transform.translation.y)

      transform.flags.incl(Dirty)
      game.createTrail(transform.translation.x, transform.translation.y)
