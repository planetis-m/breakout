import ".."/[blueprints, gametypes]

proc updateBallBounds(game: var Game; ball: var Ball) =
  let node = ball.node
  let size = ball.collide.size
  template transform: untyped = game.nodes[node.int].transform

  if ball.collide.min.x < 0:
    transform.translation.x = size.x / 2
    ball.move.direction.x *= -1

  if ball.collide.max.x > game.windowWidth.float32:
    transform.translation.x = game.windowWidth.float32 - size.x / 2
    ball.move.direction.x *= -1

  if ball.collide.min.y < 0:
    transform.translation.y = size.y / 2
    ball.move.direction.y *= -1

  if ball.collide.max.y > game.windowHeight.float32:
    transform.translation.y = game.windowHeight.float32 - size.y / 2
    ball.move.direction.y *= -1

proc updateBallCollision(game: var Game; ball: var Ball) =
  if Hit in ball.collide.collision.flags:
    template transform: untyped = game.nodes[ball.node.int].transform
    game.camera.shake.duration = 0.1

    if ball.collide.collision.hit.x != 0:
      transform.translation.x += ball.collide.collision.hit.x
      ball.move.direction.x *= -1

    if ball.collide.collision.hit.y != 0:
      transform.translation.y += ball.collide.collision.hit.y
      ball.move.direction.y *= -1

    let position = transform.translation
    game.createExplosion(position.x, position.y)

proc updateBallTrail(game: var Game; ball: Ball) =
  template transform: untyped = game.nodes[ball.node.int].transform
  let position = transform.translation
  game.markDirty(ball.node)
  game.createTrail(position.x, position.y)

proc updateBall(game: var Game; ball: var Ball) =
  game.updateBallBounds(ball)
  game.updateBallCollision(ball)
  game.updateBallTrail(ball)

proc sysControlBall*(game: var Game) =
  let ballCount = game.balls.len
  for i in 0..<ballCount:
    game.updateBall(game.balls[i])
