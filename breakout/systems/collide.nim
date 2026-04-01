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
  template collider: untyped = game.colliders[collideIdx]
  collider.collision = Collision(flags: {}, hit: vec2(0, 0))
  computeAabb(game.transforms[transformIdx], collider)

proc updateCollision(game: var Game; aIdx, bIdx: CollideIdx) =
  let a = game.colliders[aIdx]
  let b = game.colliders[bIdx]
  if intersectAabb(a, b):
    let hit = penetrateAabb(a, b)
    game.colliders[aIdx].collision = Collision(flags: {Hit}, hit: hit)
    game.colliders[bIdx].collision = Collision(flags: {Hit}, hit: -hit)

proc sysCollide*(game: var Game) =
  if game.paddle != NoActorIdx:
    let paddle = game.actors[game.paddle.int]
    if paddle.alive:
      game.prepareCollider(paddle.transform, paddle.collide)

  for actor in game.actors.items:
    if actor.alive and actor.collide != NoCollideIdx and
        actor.kind in {BallKind, BrickKind}:
      game.prepareCollider(actor.transform, actor.collide)

  for ball in game.actors.items:
    if ball.kind == BallKind and ball.alive:
      if game.paddle != NoActorIdx:
        let paddle = game.actors[game.paddle.int]
        if paddle.alive:
          game.updateCollision(ball.collide, paddle.collide)

      for brick in game.actors.items:
        if brick.kind == BrickKind and brick.alive:
          game.updateCollision(ball.collide, brick.collide)
