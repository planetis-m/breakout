import ".."/[blueprints, gamecore]

proc updateBallBounds(game: var Game; idx: BallIdx) =
  template ball: untyped = game.balls[idx.int]
  template collide: untyped = game.collides[ball.collide.int]
  template move: untyped = game.moves[ball.move.int]
  let node = ball.node
  let size = collide.size
  template transform: untyped = game.transforms[node.int]

  if collide.min.x < 0:
    transform.translation.x = size.x / 2
    move.direction.x *= -1

  if collide.max.x > game.windowWidth.float32:
    transform.translation.x = game.windowWidth.float32 - size.x / 2
    move.direction.x *= -1

  if collide.min.y < 0:
    transform.translation.y = size.y / 2
    move.direction.y *= -1

  if collide.max.y > game.windowHeight.float32:
    transform.translation.y = game.windowHeight.float32 - size.y / 2
    move.direction.y *= -1

proc updateBallCollision(game: var Game; idx: BallIdx) =
  template ball: untyped = game.balls[idx.int]
  template collide: untyped = game.collides[ball.collide.int]
  template move: untyped = game.moves[ball.move.int]
  if collide.collision.hasHit:
    template transform: untyped = game.transforms[ball.node.int]
    game.shakes[game.camera.shake.int].duration = 0.1

    if collide.collision.hit.x != 0:
      transform.translation.x += collide.collision.hit.x
      move.direction.x *= -1

    if collide.collision.hit.y != 0:
      transform.translation.y += collide.collision.hit.y
      move.direction.y *= -1

    let position = transform.translation
    game.createExplosion(position.x, position.y)

proc updateBallTrail(game: var Game; idx: BallIdx) =
  template transform: untyped = game.transforms[game.balls[idx.int].node.int]
  let position = transform.translation
  game.markDirty(game.balls[idx.int].node)
  game.createTrail(position.x, position.y)

proc updateBall(game: var Game; idx: BallIdx) =
  game.updateBallBounds(idx)
  game.updateBallCollision(idx)
  game.updateBallTrail(idx)

proc sysControlBall*(game: var Game) =
  let ballCount = game.ballCount
  for i in 0..<ballCount:
    game.updateBall(BallIdx(i.int32))
