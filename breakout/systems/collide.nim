import std/math
import ".."/[gamecore, vmath]

proc computeAabb(transform: Transform2d; collide: var Collide) =
  collide.center = transform.world.origin
  collide.min = collide.center - collide.size / 2
  collide.max = collide.center + collide.size / 2

proc intersectAabb(a, b: Collide): bool =
  result = a.min.x < b.max.x and a.min.y < b.max.y and
    a.max.x > b.min.x and a.max.y > b.min.y

proc penetrateAabb(a, b: Collide): Vec2 =
  let distanceX = a.center.x - b.center.x
  let penetrationX = a.size.x / 2 + b.size.x / 2 - abs(distanceX)
  let distanceY = a.center.y - b.center.y
  let penetrationY = a.size.y / 2 + b.size.y / 2 - abs(distanceY)

  if penetrationX < penetrationY:
    result = vec2(penetrationX * sgn(distanceX).float32, 0)
  else:
    result = vec2(0, penetrationY * sgn(distanceY).float32)

proc prepareCollider(transform: Transform2d; collide: var Collide) =
  collide.collision = Collision(hit: vec2(0, 0))
  computeAabb(transform, collide)

proc updateCollision(a, b: var Collide) =
  if intersectAabb(a, b):
    let hit = penetrateAabb(a, b)
    a.collision = Collision(hit: hit)
    b.collision = Collision(hit: -hit)

proc preparePaddleCollider(game: var Game) =
  if game.paddle.node != NoNodeIdx:
    template transform: untyped = game.transforms[game.paddle.node.int]
    prepareCollider(transform, game.collides[game.paddle.collide.int])

proc prepareBallColliders(game: var Game) =
  for ball in game.balls.mitems:
    template transform: untyped = game.transforms[ball.node.int]
    prepareCollider(transform, game.collides[ball.collide.int])

proc prepareBrickColliders(game: var Game) =
  for brick in game.bricks.mitems:
    if game.fades[brick.fade.int].step == 0:
      template transform: untyped = game.transforms[brick.node.int]
      prepareCollider(transform, game.collides[brick.collide.int])

proc collideBallWithPaddle(game: var Game; idx: BallIdx) =
  if game.paddle.node != NoNodeIdx:
    updateCollision(game.collides[game.balls[idx.int].collide.int], game.collides[game.paddle.collide.int])

proc collideBallWithBricks(game: var Game; idx: BallIdx) =
  for brick in game.bricks.mitems:
    if game.fades[brick.fade.int].step == 0:
      updateCollision(game.collides[game.balls[idx.int].collide.int], game.collides[brick.collide.int])

proc sysCollide*(game: var Game) =
  game.preparePaddleCollider()
  game.prepareBallColliders()
  game.prepareBrickColliders()

  for i in 0..<game.ballCount:
    let idx = BallIdx(i.int32)
    game.collideBallWithPaddle(idx)
    game.collideBallWithBricks(idx)
