import ".."/gametypes

proc applyFade(game: var Game; node: NodeIdx; draw: var Draw2d; fade: Fade;
    dead: var bool) =
  if draw.color[3] > 0:
    let step = 255 * fade.step
    draw.color[3] = draw.color[3] - step.uint8
    game.nodes[node.int].transform.scale.x -= fade.step
    game.nodes[node.int].transform.scale.y -= fade.step
    game.markDirty(node)
    if game.nodes[node.int].transform.scale.x <= 0:
      dead = true

proc fadeBricks(game: var Game) =
  for brick in game.bricks.mitems:
    if not brick.dead:
      game.applyFade(brick.node, brick.draw, brick.fade, brick.dead)

proc fadeParticles(game: var Game) =
  for particle in game.particles.mitems:
    if not particle.dead:
      game.applyFade(particle.node, particle.draw, particle.fade, particle.dead)

proc fadeTrails(game: var Game) =
  for trail in game.trails.mitems:
    if not trail.dead:
      game.applyFade(trail.node, trail.draw, trail.fade, trail.dead)

proc sysFade*(game: var Game) =
  game.fadeBricks()
  game.fadeParticles()
  game.fadeTrails()

proc cleanupDeadBricks(game: var Game) =
  var i = game.bricks.high
  while i >= 0:
    if game.bricks[i].dead:
      game.freeNode(game.bricks[i].node)
      game.bricks.del(i)
    dec i

proc cleanupDeadParticles(game: var Game) =
  var i = game.particles.high
  while i >= 0:
    if game.particles[i].dead:
      game.freeNode(game.particles[i].node)
      game.particles.del(i)
    dec i

proc cleanupDeadTrails(game: var Game) =
  var i = game.trails.high
  while i >= 0:
    if game.trails[i].dead:
      game.freeNode(game.trails[i].node)
      game.trails.del(i)
    dec i

proc cleanupDead*(game: var Game) =
  game.cleanupDeadBricks()
  game.cleanupDeadParticles()
  game.cleanupDeadTrails()
