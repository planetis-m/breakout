import raylib, vmath

type
  Input* = enum
    Right, Left

  CollisionFlag* = enum
    Hit

  TransformFlag* = enum
    Dirty, Fresh, HasPrevious

  ActorFlag* = enum
    Alive

  TransformIdx* = distinct int
  CollideIdx* = distinct int
  Draw2dIdx* = distinct int
  FadeIdx* = distinct int
  MoveIdx* = distinct int

  Collision* = object
    flags*: set[CollisionFlag]
    hit*: Vec2

  Hierarchy* = object
    head*: TransformIdx
    prev*: TransformIdx
    next*: TransformIdx
    parent*: TransformIdx

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

  Transform2d* = object
    world*: Mat2d
    translation*: Vec2
    rotation*: Rad
    scale*: Vec2
    previousPosition*: Point2
    previousRotation*: Rad
    previousScale*: Vec2
    flags*: set[TransformFlag]

  Shake* = object
    duration*: float32
    strength*: float32

  Camera* = object
    transform*: TransformIdx
    shake*: Shake

  Paddle* = object
    transform*: TransformIdx
    collide*: CollideIdx
    draw2d*: Draw2dIdx
    move*: MoveIdx

  Ball* = object
    flags*: set[ActorFlag]
    transform*: TransformIdx
    collide*: CollideIdx
    draw2d*: Draw2dIdx
    move*: MoveIdx

  Brick* = object
    flags*: set[ActorFlag]
    transform*: TransformIdx
    collide*: CollideIdx
    draw2d*: Draw2dIdx
    fade*: FadeIdx

  Particle* = object
    flags*: set[ActorFlag]
    transform*: TransformIdx
    draw2d*: Draw2dIdx
    fade*: FadeIdx
    move*: MoveIdx

  Trail* = object
    flags*: set[ActorFlag]
    transform*: TransformIdx
    draw2d*: Draw2dIdx
    fade*: FadeIdx

  Game* = object
    camera*: Camera
    paddle*: Paddle
    balls*: seq[Ball]
    bricks*: seq[Brick]
    particles*: seq[Particle]
    trails*: seq[Trail]

    transforms*: seq[Transform2d]
    hierarchies*: seq[Hierarchy]
    colliders*: seq[Collide]
    drawables*: seq[Draw2d]
    fades*: seq[Fade]
    moves*: seq[Move]

    freeTransforms*: seq[TransformIdx]
    freeColliders*: seq[CollideIdx]
    freeDrawables*: seq[Draw2dIdx]
    freeFades*: seq[FadeIdx]
    freeMoves*: seq[MoveIdx]

    inputState*: array[Input, bool]
    clearColor*: array[4, uint8]

    isRunning*: bool
    windowWidth*, windowHeight*: int32
    tickId*: int

    raylib*: RaylibContext

const
  NoTransformIdx* = TransformIdx(-1)
  NoCollideIdx* = CollideIdx(-1)
  NoDraw2dIdx* = Draw2dIdx(-1)
  NoFadeIdx* = FadeIdx(-1)
  NoMoveIdx* = MoveIdx(-1)

proc `==`*(a, b: TransformIdx): bool {.borrow.}
proc `==`*(a, b: CollideIdx): bool {.borrow.}
proc `==`*(a, b: Draw2dIdx): bool {.borrow.}
proc `==`*(a, b: FadeIdx): bool {.borrow.}
proc `==`*(a, b: MoveIdx): bool {.borrow.}

func containsAll*[K: enum](mask, required: set[K]): bool {.inline.} =
  required <= mask

func intersects*[K: enum](a, b: set[K]): bool {.inline.} =
  (a * b) != {}

proc prependChild(game: var Game; parent, child: TransformIdx) =
  template hierarchy: untyped = game.hierarchies[child.int]
  template parentHierarchy: untyped = game.hierarchies[parent.int]

  hierarchy.parent = parent
  hierarchy.prev = NoTransformIdx
  hierarchy.next = parentHierarchy.head
  if parentHierarchy.head != NoTransformIdx:
    game.hierarchies[parentHierarchy.head.int].prev = child
  parentHierarchy.head = child

proc removeNode(game: var Game; node: TransformIdx) =
  template hierarchy: untyped = game.hierarchies[node.int]

  let parent = hierarchy.parent
  let prev = hierarchy.prev
  let next = hierarchy.next
  let head = hierarchy.head

  if parent != NoTransformIdx and game.hierarchies[parent.int].head == node:
    game.hierarchies[parent.int].head = next
  if prev != NoTransformIdx:
    game.hierarchies[prev.int].next = next
  if next != NoTransformIdx:
    game.hierarchies[next.int].prev = prev

  hierarchy = Hierarchy(
    head: head,
    prev: NoTransformIdx,
    next: NoTransformIdx,
    parent: NoTransformIdx
  )

proc allocTransform*(game: var Game; translation = vec2(0, 0); rotation = 0.Rad;
    scale = vec2(1, 1); parent = NoTransformIdx): TransformIdx =
  let value = Transform2d(
    world: mat2d(),
    translation: translation,
    rotation: rotation,
    scale: scale,
    previousPosition: point2(0, 0),
    previousRotation: 0.Rad,
    previousScale: vec2(1, 1),
    flags: {Dirty, Fresh}
  )
  let hierarchy = Hierarchy(
    head: NoTransformIdx,
    prev: NoTransformIdx,
    next: NoTransformIdx,
    parent: NoTransformIdx
  )
  if game.freeTransforms.len > 0:
    result = game.freeTransforms.pop()
    game.transforms[result.int] = value
    game.hierarchies[result.int] = hierarchy
  else:
    result = TransformIdx(game.transforms.len)
    game.transforms.add(value)
    game.hierarchies.add(hierarchy)

  if parent != NoTransformIdx:
    game.prependChild(parent, result)

proc freeTransform*(game: var Game; idx: TransformIdx) =
  if idx != NoTransformIdx:
    game.removeNode(idx)
    game.transforms[idx.int] = default(Transform2d)
    game.hierarchies[idx.int] = default(Hierarchy)
    game.freeTransforms.add(idx)

proc allocCollide*(game: var Game; size = vec2(0, 0)): CollideIdx =
  let value = Collide(
    size: size,
    min: point2(0, 0),
    max: point2(0, 0),
    center: point2(0, 0),
    collision: Collision(flags: {}, hit: vec2(0, 0))
  )
  if game.freeColliders.len > 0:
    result = game.freeColliders.pop()
    game.colliders[result.int] = value
  else:
    result = CollideIdx(game.colliders.len)
    game.colliders.add(value)

proc freeCollide*(game: var Game; idx: CollideIdx) =
  if idx != NoCollideIdx:
    game.colliders[idx.int] = default(Collide)
    game.freeColliders.add(idx)

proc allocDraw2d*(game: var Game; width, height: int32;
    color: array[4, uint8]): Draw2dIdx =
  let value = Draw2d(width: width, height: height, color: color)
  if game.freeDrawables.len > 0:
    result = game.freeDrawables.pop()
    game.drawables[result.int] = value
  else:
    result = Draw2dIdx(game.drawables.len)
    game.drawables.add(value)

proc freeDraw2d*(game: var Game; idx: Draw2dIdx) =
  if idx != NoDraw2dIdx:
    game.drawables[idx.int] = default(Draw2d)
    game.freeDrawables.add(idx)

proc allocFade*(game: var Game; step = 0'f32): FadeIdx =
  let value = Fade(step: step)
  if game.freeFades.len > 0:
    result = game.freeFades.pop()
    game.fades[result.int] = value
  else:
    result = FadeIdx(game.fades.len)
    game.fades.add(value)

proc freeFade*(game: var Game; idx: FadeIdx) =
  if idx != NoFadeIdx:
    game.fades[idx.int] = default(Fade)
    game.freeFades.add(idx)

proc allocMove*(game: var Game; direction = vec2(0, 0); speed = 10'f32): MoveIdx =
  let value = Move(direction: direction, speed: speed)
  if game.freeMoves.len > 0:
    result = game.freeMoves.pop()
    game.moves[result.int] = value
  else:
    result = MoveIdx(game.moves.len)
    game.moves.add(value)

proc freeMove*(game: var Game; idx: MoveIdx) =
  if idx != NoMoveIdx:
    game.moves[idx.int] = default(Move)
    game.freeMoves.add(idx)

proc markDirty*(game: var Game; idx: TransformIdx) =
  if idx != NoTransformIdx:
    game.transforms[idx.int].flags.incl(Dirty)
