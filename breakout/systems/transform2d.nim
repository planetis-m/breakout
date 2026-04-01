import ".."/[gametypes, vmath]

proc updateTransformWorld(game: var Game; idx: TransformIdx; force = false) =
  template transform: untyped = game.transforms[idx]
  template previous: untyped = game.previous[idx.previousIdx]

  let shouldUpdate = force or transform.flags.intersects({Dirty, Fresh})
  if shouldUpdate:
    if Fresh in transform.flags:
      transform.flags.excl(Fresh)
    else:
      previous.position = transform.world.origin
      previous.rotation = transform.world.rotation
      previous.scale = transform.world.scale
      transform.flags.incl(HasPrevious)
      transform.flags.excl(Dirty)

    let local = compose(transform.scale, transform.rotation, transform.translation)
    let parent = game.parent(idx)
    if parent != NoTransformIdx:
      let parentTransform = game.transforms[parent]
      transform.world = parentTransform.world * local
    else:
      transform.world = local

proc updateTransformTree(game: var Game; idx: TransformIdx; force = false) =
  let subtreeDirty = force or game.transforms[idx].flags.intersects({Dirty, Fresh})

  game.updateTransformWorld(idx, force)

  var child = game.firstChild(idx)
  while child != NoTransformIdx:
    game.updateTransformTree(child, subtreeDirty)
    child = game.nextSibling(child)

proc sysTransform2d*(game: var Game) =
  game.updateTransformTree(game.camera.transform)
