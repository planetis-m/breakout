import raylib, vmath

type
  Input* = enum
    Right, Left

  CollisionFlag* = enum
    Hit

  TransformFlag* = enum
    Dirty, Fresh, HasPrevious

  NodeIdx* = distinct int32

  Collision* = object
    flags*: set[CollisionFlag]
    hit*: Vec2

  Hierarchy* = object
    head*: NodeIdx
    prev*: NodeIdx
    next*: NodeIdx
    parent*: NodeIdx

  Collide* = object
    size*: Vec2
    min*, max*: Point2
    center*: Point2
    collision*: Collision

  Draw2d* = object
    width*, height*: int32
    color*: array[4, uint8]

  Fade* = object
    step*: float32

  Move* = object
    direction*: Vec2
    speed*: float32

  Previous* = object
    position*: Point2
    rotation*: Rad
    scale*: Vec2

  Transform2d* = object
    world*: Mat2d
    translation*: Vec2
    rotation*: Rad
    scale*: Vec2
    flags*: set[TransformFlag]

  Shake* = object
    duration*: float32
    strength*: float32

  TransformNode* = object
    transform*: Transform2d
    hierarchy*: Hierarchy
    previous*: Previous
    active*: bool

  Camera* = object
    node*: NodeIdx
    shake*: Shake

  Paddle* = object
    active*: bool
    node*: NodeIdx
    collide*: Collide
    draw*: Draw2d
    move*: Move

  Ball* = object
    node*: NodeIdx
    collide*: Collide
    draw*: Draw2d
    move*: Move

  Brick* = object
    node*: NodeIdx
    collide*: Collide
    draw*: Draw2d
    fade*: Fade
    dead*: bool

  Particle* = object
    node*: NodeIdx
    draw*: Draw2d
    fade*: Fade
    move*: Move
    dead*: bool

  Trail* = object
    node*: NodeIdx
    draw*: Draw2d
    fade*: Fade
    dead*: bool

  Game* = object
    camera*: Camera
    paddle*: Paddle
    balls*: seq[Ball]
    bricks*: seq[Brick]
    particles*: seq[Particle]
    trails*: seq[Trail]

    nodes*: seq[TransformNode]
    freeNodes*: seq[int32]

    inputState*: array[Input, bool]
    clearColor*: array[4, uint8]

    isRunning*: bool
    windowWidth*, windowHeight*: int32
    tickId*: int

    raylib*: RaylibContext

const
  NoNodeIdx* = NodeIdx(-1'i32)

proc `==`*(a, b: NodeIdx): bool {.borrow.}

func intersects*[K: enum](a, b: set[K]): bool {.inline.} =
  (a * b) != {}

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
    ),
    active: true
  )

proc parent*(game: Game; idx: NodeIdx): NodeIdx =
  result = game.nodes[idx.int].hierarchy.parent

proc firstChild*(game: Game; idx: NodeIdx): NodeIdx =
  result = game.nodes[idx.int].hierarchy.head

proc nextSibling*(game: Game; idx: NodeIdx): NodeIdx =
  result = game.nodes[idx.int].hierarchy.next

proc prependChild(game: var Game; parent, child: NodeIdx) =
  let head = game.nodes[parent.int].hierarchy.head

  game.nodes[child.int].hierarchy.parent = parent
  game.nodes[child.int].hierarchy.prev = NoNodeIdx
  game.nodes[child.int].hierarchy.next = head
  if head != NoNodeIdx:
    game.nodes[head.int].hierarchy.prev = child
  game.nodes[parent.int].hierarchy.head = child

proc removeNode(game: var Game; node: NodeIdx) =
  let parent = game.nodes[node.int].hierarchy.parent
  let prev = game.nodes[node.int].hierarchy.prev
  let next = game.nodes[node.int].hierarchy.next
  let head = game.nodes[node.int].hierarchy.head

  if parent != NoNodeIdx and game.nodes[parent.int].hierarchy.head == node:
    game.nodes[parent.int].hierarchy.head = next
  if prev != NoNodeIdx:
    game.nodes[prev.int].hierarchy.next = next
  if next != NoNodeIdx:
    game.nodes[next.int].hierarchy.prev = prev

  game.nodes[node.int].hierarchy = Hierarchy(
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
  game.nodes[idx.int].active = false
  game.freeNodes.add(idx.int32)

proc markDirty*(game: var Game; idx: NodeIdx) =
  if idx != NoNodeIdx:
    game.nodes[idx.int].transform.flags.incl(Dirty)

proc initCollide*(size: Vec2): Collide =
  result = Collide(
    size: size,
    min: point2(0, 0),
    max: point2(0, 0),
    center: point2(0, 0),
    collision: Collision(flags: {}, hit: vec2(0, 0))
  )
