import ".."/[gametypes, vmath]

proc updateTransformWorld(game: var Game; idx: NodeIdx) =
  template transformNode: untyped = game.nodes[idx.int]
  template transform: untyped = transformNode.transform
  template previous: untyped = transformNode.previous

  if Fresh in transform.flags:
    transform.flags.excl(Fresh)
  else:
    previous.position = transform.world.origin
    previous.rotation = transform.world.rotation
    previous.scale = transform.world.scale
    transform.flags.incl(HasPrevious)
    transform.flags.excl(Dirty)

  let local = compose(
    transform.scale,
    transform.rotation,
    transform.translation
  )
  let parent = game.parent(idx)
  if parent != NoNodeIdx:
    template parentTransform: untyped = game.nodes[parent.int].transform
    transform.world = parentTransform.world * local
  else:
    transform.world = local

proc sysTransform2d*(game: var Game) =
  var stack: seq[NodeIdx] = @[]
  var current = game.camera.node

  while current != NoNodeIdx:
    let sibling = game.nextSibling(current)
    if sibling != NoNodeIdx:
      stack.add(sibling)

    template transform: untyped = game.nodes[current.int].transform
    if transform.flags.intersects({Dirty, Fresh}):
      game.updateTransformWorld(current)

    let child = game.firstChild(current)
    if child != NoNodeIdx:
      current = child
    elif stack.len > 0:
      current = stack.pop()
    else:
      current = NoNodeIdx
