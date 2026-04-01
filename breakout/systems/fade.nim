import ".."/gametypes

proc updateFading(game: var Game; transformIdx: TransformIdx; drawIdx: Draw2dIdx;
    fadeIdx: FadeIdx; flags: var set[ActorFlag]) =
  template transform: untyped = game.transforms[transformIdx.int]
  template draw: untyped = game.drawables[drawIdx.int]
  let fade = game.fades[fadeIdx.int]

  if draw.color[3] > 0:
    let step = 255 * fade.step
    draw.color[3] = draw.color[3] - step.uint8
    transform.scale.x -= fade.step
    transform.scale.y -= fade.step
    transform.flags.incl(Dirty)

    if transform.scale.x <= 0:
      flags.excl(Alive)

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
    if Alive notin game.balls[i].flags:
      game.freeBall(game.balls[i])
      game.balls.del(i)

  for i in countdown(game.bricks.high, 0):
    if Alive notin game.bricks[i].flags:
      game.freeBrick(game.bricks[i])
      game.bricks.del(i)

  for i in countdown(game.particles.high, 0):
    if Alive notin game.particles[i].flags:
      game.freeParticle(game.particles[i])
      game.particles.del(i)

  for i in countdown(game.trails.high, 0):
    if Alive notin game.trails[i].flags:
      game.freeTrail(game.trails[i])
      game.trails.del(i)

proc sysFade*(game: var Game) =
  for brick in mitems(game.bricks):
    if Alive in brick.flags:
      game.updateFading(brick.transform, brick.draw2d, brick.fade, brick.flags)

  for particle in mitems(game.particles):
    if Alive in particle.flags:
      game.updateFading(particle.transform, particle.draw2d, particle.fade, particle.flags)

  for trail in mitems(game.trails):
    if Alive in trail.flags:
      game.updateFading(trail.transform, trail.draw2d, trail.fade, trail.flags)
