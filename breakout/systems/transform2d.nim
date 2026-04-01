import ".."/[gametypes, vmath]

proc updateTransformWorld(game: var Game; idx: TransformIdx) =
  template transform: untyped = game.transforms[idx]
  template previous: untyped = game.previous[idx.previousIdx]

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
  var stack: seq[TransformIdx] = @[]
  var current = game.camera.transform

  while current != NoTransformIdx:
    let sibling = game.nextSibling(current)
    if sibling != NoTransformIdx:
      stack.add(sibling)

    if game.transforms[current].flags.intersects({Dirty, Fresh}):
      game.updateTransformWorld(current)

    let child = game.firstChild(current)
    if child != NoTransformIdx:
      current = child
    elif stack.len > 0:
      current = stack.pop()
    else:
      current = NoTransformIdx
