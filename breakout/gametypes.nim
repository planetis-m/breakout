import raylib, vmath, pools
export pools

type
  Input* = enum
    Right, Left

  CollisionFlag* = enum
    Hit

  TransformFlag* = enum
    Dirty, Fresh, HasPrevious

  ActorKind* = enum
    DeadKind,
    PaddleKind,
    BallKind,
    BrickKind,
    ParticleKind,
    TrailKind

  ActorIdx* = distinct int
  TransformIdx* = distinct int
  HierarchyIdx* = distinct int
  PreviousIdx* = distinct int
  CollideIdx* = distinct int
  Draw2dIdx* = distinct int
  FadeIdx* = distinct int
  MoveIdx* = distinct int

  Collision* = object
    flags*: set[CollisionFlag]
    hit*: Vec2

  Hierarchy* = object
    head*: HierarchyIdx
    prev*: HierarchyIdx
    next*: HierarchyIdx
    parent*: HierarchyIdx

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

  Camera* = object
    transform*: TransformIdx
    shake*: Shake

  Actor* = object
    kind*: ActorKind
    transform*: TransformIdx
    collide*: CollideIdx
    draw2d*: Draw2dIdx
    fade*: FadeIdx
    move*: MoveIdx

  Game* = object
    camera*: Camera
    paddle*: ActorIdx
    actors*: seq[Actor]

    transforms*: Pool[Transform2d, TransformIdx]
    hierarchies*: Pool[Hierarchy, HierarchyIdx]
    previous*: Pool[Previous, PreviousIdx]
    colliders*: Pool[Collide, CollideIdx]
    drawables*: Pool[Draw2d, Draw2dIdx]
    fades*: Pool[Fade, FadeIdx]
    moves*: Pool[Move, MoveIdx]

    inputState*: array[Input, bool]
    clearColor*: array[4, uint8]

    isRunning*: bool
    windowWidth*, windowHeight*: int32
    tickId*: int

    raylib*: RaylibContext

const
  NoActorIdx* = ActorIdx(-1)
  NoTransformIdx* = TransformIdx(-1)
  NoHierarchyIdx* = HierarchyIdx(-1)
  NoPreviousIdx* = PreviousIdx(-1)
  NoCollideIdx* = CollideIdx(-1)
  NoDraw2dIdx* = Draw2dIdx(-1)
  NoFadeIdx* = FadeIdx(-1)
  NoMoveIdx* = MoveIdx(-1)

proc `==`*(a, b: ActorIdx): bool {.borrow.}
proc `==`*(a, b: TransformIdx): bool {.borrow.}
proc `==`*(a, b: HierarchyIdx): bool {.borrow.}
proc `==`*(a, b: PreviousIdx): bool {.borrow.}
proc `==`*(a, b: CollideIdx): bool {.borrow.}
proc `==`*(a, b: Draw2dIdx): bool {.borrow.}
proc `==`*(a, b: FadeIdx): bool {.borrow.}
proc `==`*(a, b: MoveIdx): bool {.borrow.}

func containsAll*[K: enum](mask, required: set[K]): bool {.inline.} =
  required <= mask

func intersects*[K: enum](a, b: set[K]): bool {.inline.} =
  (a * b) != {}

func hierarchyIdx*(idx: TransformIdx): HierarchyIdx {.inline.} =
  HierarchyIdx(idx.int)

func previousIdx*(idx: TransformIdx): PreviousIdx {.inline.} =
  PreviousIdx(idx.int)

func transformIdx*(idx: HierarchyIdx): TransformIdx {.inline.} =
  TransformIdx(idx.int)

proc parent*(game: Game; idx: TransformIdx): TransformIdx =
  let parentHierarchyIdx = game.hierarchies[idx.hierarchyIdx].parent
  if parentHierarchyIdx == NoHierarchyIdx:
    result = NoTransformIdx
  else:
    result = parentHierarchyIdx.transformIdx

proc firstChild*(game: Game; idx: TransformIdx): TransformIdx =
  let childHierarchyIdx = game.hierarchies[idx.hierarchyIdx].head
  if childHierarchyIdx == NoHierarchyIdx:
    result = NoTransformIdx
  else:
    result = childHierarchyIdx.transformIdx

proc nextSibling*(game: Game; idx: TransformIdx): TransformIdx =
  let siblingHierarchyIdx = game.hierarchies[idx.hierarchyIdx].next
  if siblingHierarchyIdx == NoHierarchyIdx:
    result = NoTransformIdx
  else:
    result = siblingHierarchyIdx.transformIdx

proc prependChild(game: var Game; parent, child: TransformIdx) =
  let childHierarchyIdx = child.hierarchyIdx
  let parentHierarchyIdx = parent.hierarchyIdx
  template hierarchy: untyped = game.hierarchies[childHierarchyIdx]
  template parentHierarchy: untyped = game.hierarchies[parentHierarchyIdx]

  hierarchy.parent = parentHierarchyIdx
  hierarchy.prev = NoHierarchyIdx
  hierarchy.next = parentHierarchy.head
  if parentHierarchy.head != NoHierarchyIdx:
    game.hierarchies[parentHierarchy.head].prev = childHierarchyIdx
  parentHierarchy.head = childHierarchyIdx

proc removeNode(game: var Game; node: TransformIdx) =
  let idx = node.hierarchyIdx
  template hierarchy: untyped = game.hierarchies[idx]

  let parent = hierarchy.parent
  let prev = hierarchy.prev
  let next = hierarchy.next
  let head = hierarchy.head

  if parent != NoHierarchyIdx and game.hierarchies[parent].head == idx:
    game.hierarchies[parent].head = next
  if prev != NoHierarchyIdx:
    game.hierarchies[prev].next = next
  if next != NoHierarchyIdx:
    game.hierarchies[next].prev = prev

  hierarchy = Hierarchy(
    head: head,
    prev: NoHierarchyIdx,
    next: NoHierarchyIdx,
    parent: NoHierarchyIdx
  )

proc allocTransform*(game: var Game; translation = vec2(0, 0); rotation = 0.Rad;
    scale = vec2(1, 1); parent = NoTransformIdx): TransformIdx =
  let transform = Transform2d(
    world: mat2d(),
    translation: translation,
    rotation: rotation,
    scale: scale,
    flags: {Dirty, Fresh}
  )
  let hierarchy = Hierarchy(
    head: NoHierarchyIdx,
    prev: NoHierarchyIdx,
    next: NoHierarchyIdx,
    parent: NoHierarchyIdx
  )
  let previous = Previous(
    position: point2(0, 0),
    rotation: 0.Rad,
    scale: vec2(1, 1)
  )
  let transformIdx = game.transforms.alloc(transform)
  let hierarchyIdx = game.hierarchies.alloc(hierarchy)
  let previousIdx = game.previous.alloc(previous)
  doAssert hierarchyIdx.int == transformIdx.int
  doAssert previousIdx.int == transformIdx.int
  result = transformIdx

  if parent != NoTransformIdx:
    game.prependChild(parent, result)

proc freeTransform*(game: var Game; idx: TransformIdx) =
  if idx != NoTransformIdx:
    game.removeNode(idx)
    game.transforms.free(idx)
    game.hierarchies.free(idx.hierarchyIdx)
    game.previous.free(idx.previousIdx)

proc allocCollide*(game: var Game; size = vec2(0, 0)): CollideIdx =
  let value = Collide(
    size: size,
    min: point2(0, 0),
    max: point2(0, 0),
    center: point2(0, 0),
    collision: Collision(flags: {}, hit: vec2(0, 0))
  )
  result = game.colliders.alloc(value)

proc freeCollide*(game: var Game; idx: CollideIdx) =
  if idx != NoCollideIdx:
    game.colliders.free(idx)

proc allocDraw2d*(game: var Game; width, height: int32;
    color: array[4, uint8]): Draw2dIdx =
  let value = Draw2d(width: width, height: height, color: color)
  result = game.drawables.alloc(value)

proc freeDraw2d*(game: var Game; idx: Draw2dIdx) =
  if idx != NoDraw2dIdx:
    game.drawables.free(idx)

proc allocFade*(game: var Game; step = 0'f32): FadeIdx =
  let value = Fade(step: step)
  result = game.fades.alloc(value)

proc freeFade*(game: var Game; idx: FadeIdx) =
  if idx != NoFadeIdx:
    game.fades.free(idx)

proc allocMove*(game: var Game; direction = vec2(0, 0); speed = 10'f32): MoveIdx =
  let value = Move(direction: direction, speed: speed)
  result = game.moves.alloc(value)

proc freeMove*(game: var Game; idx: MoveIdx) =
  if idx != NoMoveIdx:
    game.moves.free(idx)

proc addActor*(game: var Game; kind: ActorKind; transform: TransformIdx;
    collide = NoCollideIdx; draw2d = NoDraw2dIdx; fade = NoFadeIdx;
    move = NoMoveIdx): ActorIdx =
  let actor = Actor(
    kind: kind,
    transform: transform,
    collide: collide,
    draw2d: draw2d,
    fade: fade,
    move: move
  )
  result = ActorIdx(game.actors.len)
  game.actors.add(actor)

proc freeActorResources*(game: var Game; actor: Actor) =
  game.freeTransform(actor.transform)
  game.freeCollide(actor.collide)
  game.freeDraw2d(actor.draw2d)
  game.freeFade(actor.fade)
  game.freeMove(actor.move)

proc removeActor*(game: var Game; idx: ActorIdx) =
  if idx == NoActorIdx:
    return

  let lastIdx = ActorIdx(game.actors.high)
  if game.paddle == idx:
    game.paddle = NoActorIdx
  elif idx != lastIdx and game.paddle == lastIdx:
    game.paddle = idx

  game.freeActorResources(game.actors[idx.int])
  game.actors.del(idx.int)

proc markDirty*(game: var Game; idx: TransformIdx) =
  if idx != NoTransformIdx:
    game.transforms[idx].flags.incl(Dirty)
