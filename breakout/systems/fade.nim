import ".."/gamecore

proc applyFade(game: var Game; node: NodeIdx; draw: var Draw2d; fade: Fade) =
  if fade.step > 0 and draw.color.a > 0:
    template transform: untyped = game.nodes[node.int].transform
    let step = (255 * fade.step).uint8
    draw.color.a = draw.color.a - step
    transform.scale.x -= fade.step
    transform.scale.y -= fade.step
    game.markDirty(node)

proc fadeBricks(game: var Game) =
  for brick in game.bricks.mitems:
    game.applyFade(brick.node, brick.draw, brick.fade)

proc fadeParticles(game: var Game) =
  for particle in game.particles.mitems:
    game.applyFade(particle.node, particle.draw, particle.fade)

proc fadeTrails(game: var Game) =
  for trail in game.trails.mitems:
    game.applyFade(trail.node, trail.draw, trail.fade)

func shouldCleanup(game: Game; node: NodeIdx): bool =
  template transform: untyped = game.nodes[node.int].transform
  result = transform.scale.x <= 0

proc sysFade*(game: var Game) =
  game.fadeBricks()
  game.fadeParticles()
  game.fadeTrails()

proc cleanupDeadBricks(game: var Game) =
  var i = game.bricks.high
  while i >= 0:
    if game.shouldCleanup(game.bricks[i].node):
      game.freeNode(game.bricks[i].node)
      game.bricks.del(i)
    dec i

proc cleanupDeadParticles(game: var Game) =
  var i = game.particles.high
  while i >= 0:
    if game.shouldCleanup(game.particles[i].node):
      game.freeNode(game.particles[i].node)
      game.particles.del(i)
    dec i

proc cleanupDeadTrails(game: var Game) =
  var i = game.trails.high
  while i >= 0:
    if game.shouldCleanup(game.trails[i].node):
      game.freeNode(game.trails[i].node)
      game.trails.del(i)
    dec i

proc cleanupDead*(game: var Game) =
  game.cleanupDeadBricks()
  game.cleanupDeadParticles()
  game.cleanupDeadTrails()
