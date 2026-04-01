import ".."/gamecore

proc applyFade(game: var Game; node: NodeIdx; draw: var Draw2d; fade: Fade) =
  if fade.step > 0 and draw.color[3] > 0:
    template transform: untyped = game.nodes[node.int].transform
    let step = 255 * fade.step
    draw.color[3] = draw.color[3] - step.uint8
    transform.scale.x -= fade.step
    transform.scale.y -= fade.step
    game.markDirty(node)

proc fadeBricks(game: var Game) =
  for brick in game.bricks.mitems:
    game.applyFade(brick.node, game.draws[brick.draw.int], game.fades[brick.fade.int])

proc fadeParticles(game: var Game) =
  for particle in game.particles.mitems:
    game.applyFade(particle.node, game.draws[particle.draw.int], game.fades[particle.fade.int])

proc fadeTrails(game: var Game) =
  for trail in game.trails.mitems:
    game.applyFade(trail.node, game.draws[trail.draw.int], game.fades[trail.fade.int])

func shouldCleanup(game: Game; node: NodeIdx): bool =
  template transform: untyped = game.nodes[node.int].transform
  result = transform.scale.x <= 0

proc sysFade*(game: var Game) =
  game.fadeBricks()
  game.fadeParticles()
  game.fadeTrails()

proc cleanupDeadBricks(game: var Game) =
  var i = game.brickCount - 1
  while i >= 0:
    if game.shouldCleanup(game.bricks[i].node):
      game.deleteBrick(BrickIdx(i.int32))
    dec i

proc cleanupDeadParticles(game: var Game) =
  var i = game.particleCount - 1
  while i >= 0:
    if game.shouldCleanup(game.particles[i].node):
      game.deleteParticle(ParticleIdx(i.int32))
    dec i

proc cleanupDeadTrails(game: var Game) =
  var i = game.trailCount - 1
  while i >= 0:
    if game.shouldCleanup(game.trails[i].node):
      game.deleteTrail(TrailIdx(i.int32))
    dec i

proc cleanupDead*(game: var Game) =
  game.cleanupDeadBricks()
  game.cleanupDeadParticles()
  game.cleanupDeadTrails()
