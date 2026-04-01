import ".."/[gametypes, vmath]

proc updateTransformWorld(game: var Game; idx: NodeIdx) =
  if Fresh in game.nodes[idx.int].transform.flags:
    game.nodes[idx.int].transform.flags.excl(Fresh)
  else:
    game.nodes[idx.int].previous.position = game.nodes[idx.int].transform.world.origin
    game.nodes[idx.int].previous.rotation = game.nodes[idx.int].transform.world.rotation
    game.nodes[idx.int].previous.scale = game.nodes[idx.int].transform.world.scale
    game.nodes[idx.int].transform.flags.incl(HasPrevious)
    game.nodes[idx.int].transform.flags.excl(Dirty)

  let local = compose(
    game.nodes[idx.int].transform.scale,
    game.nodes[idx.int].transform.rotation,
    game.nodes[idx.int].transform.translation
  )
  let parent = game.parent(idx)
  if parent != NoNodeIdx:
    game.nodes[idx.int].transform.world = game.nodes[parent.int].transform.world * local
  else:
    game.nodes[idx.int].transform.world = local

proc sysTransform2d*(game: var Game) =
  var stack: seq[NodeIdx] = @[]
  var current = game.camera.node

  while current != NoNodeIdx:
    let sibling = game.nextSibling(current)
    if sibling != NoNodeIdx:
      stack.add(sibling)

    if game.nodes[current.int].transform.flags.intersects({Dirty, Fresh}):
      game.updateTransformWorld(current)

    let child = game.firstChild(current)
    if child != NoNodeIdx:
      current = child
    elif stack.len > 0:
      current = stack.pop()
    else:
      current = NoNodeIdx
