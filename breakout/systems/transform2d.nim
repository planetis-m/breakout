import ".."/[gamecore, vmath]

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
  if parent ?= game.parent(idx):
    template parentTransform: untyped = game.nodes[parent.int].transform
    transform.world = parentTransform.world * local
  else:
    transform.world = local

proc sysTransform2d*(game: var Game) =
  var stack: seq[NodeIdx] = @[]
  var current = game.camera.node

  while current != NoNodeIdx:
    if sibling ?= game.nextSibling(current):
      stack.add(sibling)

    template transform: untyped = game.nodes[current.int].transform
    if transform.flags.intersects({Dirty, Fresh}):
      game.updateTransformWorld(current)

    if child ?= game.firstChild(current):
      current = child
    elif stack.len > 0:
      current = stack.pop()
    else:
      current = NoNodeIdx
