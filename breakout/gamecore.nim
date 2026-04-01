import gametypes, vmath

export gametypes

const
  NoNodeIdx* = NodeIdx(-1'i32)

proc `==`*(a, b: NodeIdx): bool {.borrow.}

func intersects*[K: enum](a, b: set[K]): bool {.inline.} =
  result = (a * b) != {}

proc initTransformNode(translation: Vec2): TransformNode =
  result = TransformNode(
    transform: Transform2d(
      world: mat2d(),
      translation: translation,
      rotation: 0.Rad,
      scale: vec2(1, 1),
      flags: {Dirty, Fresh}
    ),
    hierarchy: Hierarchy(
      head: NoNodeIdx,
      prev: NoNodeIdx,
      next: NoNodeIdx,
      parent: NoNodeIdx
    ),
    previous: Previous(
      position: point2(0, 0),
      rotation: 0.Rad,
      scale: vec2(1, 1)
    )
  )

proc parent*(game: Game; idx: NodeIdx): NodeIdx =
  template hierarchy: untyped = game.nodes[idx.int].hierarchy
  result = hierarchy.parent

proc firstChild*(game: Game; idx: NodeIdx): NodeIdx =
  template hierarchy: untyped = game.nodes[idx.int].hierarchy
  result = hierarchy.head

proc nextSibling*(game: Game; idx: NodeIdx): NodeIdx =
  template hierarchy: untyped = game.nodes[idx.int].hierarchy
  result = hierarchy.next

proc prependChild(game: var Game; parent, child: NodeIdx) =
  template childHierarchy: untyped = game.nodes[child.int].hierarchy
  template parentHierarchy: untyped = game.nodes[parent.int].hierarchy
  let head = parentHierarchy.head

  childHierarchy.parent = parent
  childHierarchy.prev = NoNodeIdx
  childHierarchy.next = head
  if head != NoNodeIdx:
    game.nodes[head.int].hierarchy.prev = child
  parentHierarchy.head = child

proc removeNode(game: var Game; node: NodeIdx) =
  template hierarchy: untyped = game.nodes[node.int].hierarchy
  let parent = hierarchy.parent
  let prev = hierarchy.prev
  let next = hierarchy.next
  let head = hierarchy.head

  if parent != NoNodeIdx and game.nodes[parent.int].hierarchy.head == node:
    game.nodes[parent.int].hierarchy.head = next
  if prev != NoNodeIdx:
    game.nodes[prev.int].hierarchy.next = next
  if next != NoNodeIdx:
    game.nodes[next.int].hierarchy.prev = prev

  hierarchy = Hierarchy(
    head: head,
    prev: NoNodeIdx,
    next: NoNodeIdx,
    parent: NoNodeIdx
  )

proc allocNode*(game: var Game; translation: Vec2; parent = NoNodeIdx): NodeIdx =
  if game.freeNodes.len > 0:
    result = NodeIdx(game.freeNodes.pop())
    game.nodes[result.int] = initTransformNode(translation)
  else:
    result = NodeIdx(game.nodes.len.int32)
    game.nodes.add(initTransformNode(translation))

  if parent != NoNodeIdx:
    game.prependChild(parent, result)

proc freeNode*(game: var Game; idx: NodeIdx) =
  if idx == NoNodeIdx:
    return

  game.removeNode(idx)
  game.freeNodes.add(idx.int32)

proc markDirty*(game: var Game; idx: NodeIdx) =
  if idx != NoNodeIdx:
    template transform: untyped = game.nodes[idx.int].transform
    transform.flags.incl(Dirty)

proc initCollide*(size: Vec2): Collide =
  result = Collide(
    size: size,
    min: point2(0, 0),
    max: point2(0, 0),
    center: point2(0, 0),
    collision: Collision(hit: vec2(0, 0))
  )

func hasHit*(collision: Collision): bool {.inline.} =
  result = collision.hit.x != 0 or collision.hit.y != 0
