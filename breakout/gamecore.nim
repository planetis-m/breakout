import gametypes, vmath

export gametypes

const
  NoNodeIdx* = NodeIdx(-1'i32)

proc `==`*(a, b: NodeIdx): bool {.borrow.}
template `?=`*(name, value): bool = (let name = value; name != NoNodeIdx)

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
  template node: untyped = game.nodes[idx.int]
  result = node.hierarchy.parent

proc firstChild*(game: Game; idx: NodeIdx): NodeIdx =
  template node: untyped = game.nodes[idx.int]
  result = node.hierarchy.head

proc nextSibling*(game: Game; idx: NodeIdx): NodeIdx =
  template node: untyped = game.nodes[idx.int]
  result = node.hierarchy.next

proc prependChild(game: var Game; parent, child: NodeIdx) =
  template childHierarchy: untyped = game.nodes[child.int].hierarchy
  template parentHierarchy: untyped = game.nodes[parent.int].hierarchy
  template head: untyped = parentHierarchy.head
  template firstChild: untyped = game.nodes[headId.int].hierarchy

  childHierarchy.parent = parent
  childHierarchy.prev = NoNodeIdx
  childHierarchy.next = head
  if headId ?= head:
    firstChild.prev = child
  parentHierarchy.head = child

proc removeNode(game: var Game; node: NodeIdx) =
  template hierarchy: untyped = game.nodes[node.int].hierarchy
  template parent: untyped = game.nodes[parentId.int].hierarchy
  template nextSibling: untyped = game.nodes[nextSiblingId.int].hierarchy
  template prevSibling: untyped = game.nodes[prevSiblingId.int].hierarchy
  let head = hierarchy.head

  if parentId ?= hierarchy.parent:
    if parent.head == node:
      parent.head = hierarchy.next
  if nextSiblingId ?= hierarchy.next:
    nextSibling.prev = hierarchy.prev
  if prevSiblingId ?= hierarchy.prev:
    prevSibling.next = hierarchy.next

  hierarchy = Hierarchy(
    head: head,
    prev: NoNodeIdx,
    next: NoNodeIdx,
    parent: NoNodeIdx
  )

proc allocNode*(game: var Game; translation: Vec2; parent = NoNodeIdx): NodeIdx =
  if game.freeNodes.len > 0:
    let freeNodeId = NodeIdx(game.freeNodes.pop())
    game.nodes[freeNodeId.int] = initTransformNode(translation)
    result = freeNodeId
  else:
    let nodeId = NodeIdx(game.nodes.len.int32)
    game.nodes.add(initTransformNode(translation))
    result = nodeId

  if parentId ?= parent:
    game.prependChild(parentId, result)

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
