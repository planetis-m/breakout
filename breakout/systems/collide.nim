import std/math
import ".."/[gametypes, vmath]

proc computeAabb(transform: Transform2d; collide: var Collide) =
  collide.center = transform.world.origin
  collide.min = collide.center - collide.size / 2
  collide.max = collide.center + collide.size / 2

proc intersectAabb(a, b: Collide): bool =
  a.min.x < b.max.x and a.min.y < b.max.y and
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

proc prepareCollider(game: var Game; transformIdx: TransformIdx; collideIdx: CollideIdx) =
  template collider: untyped = game.colliders[collideIdx.int]
  collider.collision = Collision(hasHit: false, hit: vec2(0, 0))
  computeAabb(game.transforms[transformIdx.int], collider)

proc updateCollision(game: var Game; aIdx, bIdx: CollideIdx) =
  let a = game.colliders[aIdx.int]
  let b = game.colliders[bIdx.int]
  if intersectAabb(a, b):
    let hit = penetrateAabb(a, b)
    game.colliders[aIdx.int].collision = Collision(hasHit: true, hit: hit)
    game.colliders[bIdx.int].collision = Collision(hasHit: true, hit: -hit)

proc sysCollide*(game: var Game) =
  game.prepareCollider(game.paddle.transform, game.paddle.collide)

  for ball in game.balls.items:
    if ball.alive:
      game.prepareCollider(ball.transform, ball.collide)

  for brick in game.bricks.items:
    if brick.alive:
      game.prepareCollider(brick.transform, brick.collide)

  for ball in game.balls.items:
    if ball.alive:
      game.updateCollision(ball.collide, game.paddle.collide)
      for brick in game.bricks.items:
        if brick.alive:
          game.updateCollision(ball.collide, brick.collide)
