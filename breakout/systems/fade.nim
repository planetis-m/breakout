import ".."/gametypes

proc updateFading(game: var Game; transformIdx: TransformIdx; drawIdx: Draw2dIdx;
    fadeIdx: FadeIdx; alive: var bool) =
  var transform = addr game.transforms[transformIdx.int]
  var draw = addr game.drawables[drawIdx.int]
  let fade = game.fades[fadeIdx.int]

  if draw.color[3] > 0:
    let step = 255 * fade.step
    draw.color[3] = draw.color[3] - step.uint8
    transform.scale.x -= fade.step
    transform.scale.y -= fade.step
    transform.dirty = true

    if transform.scale.x <= 0:
      alive = false

proc freeBall(game: var Game; ball: Ball) =
  game.freeTransform(ball.transform)
  game.freeCollide(ball.collide)
  game.freeDraw2d(ball.draw2d)
  game.freeMove(ball.move)

proc freeBrick(game: var Game; brick: Brick) =
  game.freeTransform(brick.transform)
  game.freeCollide(brick.collide)
  game.freeDraw2d(brick.draw2d)
  game.freeFade(brick.fade)

proc freeParticle(game: var Game; particle: Particle) =
  game.freeTransform(particle.transform)
  game.freeDraw2d(particle.draw2d)
  game.freeFade(particle.fade)
  game.freeMove(particle.move)

proc freeTrail(game: var Game; trail: Trail) =
  game.freeTransform(trail.transform)
  game.freeDraw2d(trail.draw2d)
  game.freeFade(trail.fade)

proc cleanupDead*(game: var Game) =
  for i in countdown(game.balls.high, 0):
    if not game.balls[i].alive:
      game.freeBall(game.balls[i])
      game.balls.del(i)

  for i in countdown(game.bricks.high, 0):
    if not game.bricks[i].alive:
      game.freeBrick(game.bricks[i])
      game.bricks.del(i)

  for i in countdown(game.particles.high, 0):
    if not game.particles[i].alive:
      game.freeParticle(game.particles[i])
      game.particles.del(i)

  for i in countdown(game.trails.high, 0):
    if not game.trails[i].alive:
      game.freeTrail(game.trails[i])
      game.trails.del(i)

proc sysFade*(game: var Game) =
  for brick in mitems(game.bricks):
    if brick.alive:
      game.updateFading(brick.transform, brick.draw2d, brick.fade, brick.alive)

  for particle in mitems(game.particles):
    if particle.alive:
      game.updateFading(particle.transform, particle.draw2d, particle.fade, particle.alive)

  for trail in mitems(game.trails):
    if trail.alive:
      game.updateFading(trail.transform, trail.draw2d, trail.fade, trail.alive)
