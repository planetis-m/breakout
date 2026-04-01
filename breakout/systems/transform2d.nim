import ".."/[gametypes, vmath]

proc updateTransformWorld(game: var Game; idx: TransformIdx; force = false) =
  var transform = addr game.transforms[idx.int]
  if not transform.active:
    return

  let shouldUpdate = force or transform.dirty or transform.fresh
  if shouldUpdate:
    if not transform.fresh:
      let position = transform.world.origin
      let rotation = transform.world.rotation
      let scale = transform.world.scale
      transform.previousPosition = position
      transform.previousRotation = rotation
      transform.previousScale = scale
      transform.hasPrevious = true
      transform.dirty = false
    else:
      transform.fresh = false

    let local = compose(transform.scale, transform.rotation, transform.translation)
    if transform.parent != NoTransformIdx:
      let parentTransform = game.transforms[transform.parent.int]
      transform.world = parentTransform.world * local
    else:
      transform.world = local

proc sysTransform2d*(game: var Game) =
  let cameraDirty = game.transforms[game.camera.transform.int].dirty or
    game.transforms[game.camera.transform.int].fresh

  game.updateTransformWorld(game.camera.transform)
  game.updateTransformWorld(game.paddle.transform, cameraDirty)

  for ball in game.balls.items:
    if ball.alive:
      game.updateTransformWorld(ball.transform, cameraDirty)

  for brick in game.bricks.items:
    if brick.alive:
      game.updateTransformWorld(brick.transform, cameraDirty)

  for particle in game.particles.items:
    if particle.alive:
      game.updateTransformWorld(particle.transform, cameraDirty)

  for trail in game.trails.items:
    if trail.alive:
      game.updateTransformWorld(trail.transform, cameraDirty)
