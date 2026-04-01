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

proc sysTransform2d*(game: var Game) =
  var stack: seq[tuple[idx: TransformIdx, force: bool]] = @[]
  var current = game.camera.transform
  var currentForce = false

  while current != NoTransformIdx:
    let subtreeDirty = currentForce or game.transforms[current].flags.intersects({Dirty, Fresh})
    let sibling = game.nextSibling(current)
    if sibling != NoTransformIdx:
      stack.add((sibling, currentForce))

    game.updateTransformWorld(current, currentForce)

    let child = game.firstChild(current)
    if child != NoTransformIdx:
      current = child
      currentForce = subtreeDirty
    elif stack.len > 0:
      (current, currentForce) = stack.pop()
    else:
      current = NoTransformIdx
