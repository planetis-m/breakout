import gametypes, vmath

export gametypes

const
  NoNodeIdx* = NodeIdx(-1'i32)

proc `==`*(a, b: NodeIdx): bool {.borrow.}
proc `==`*(a, b: BallIdx): bool {.borrow.}
proc `==`*(a, b: BrickIdx): bool {.borrow.}
proc `==`*(a, b: ParticleIdx): bool {.borrow.}
proc `==`*(a, b: TrailIdx): bool {.borrow.}
proc `==`*(a, b: CollideIdx): bool {.borrow.}
proc `==`*(a, b: Draw2dIdx): bool {.borrow.}
proc `==`*(a, b: FadeIdx): bool {.borrow.}
proc `==`*(a, b: MoveIdx): bool {.borrow.}
proc `==`*(a, b: ShakeIdx): bool {.borrow.}

func intersects*[K: enum](a, b: set[K]): bool {.inline.} =
  result = (a * b) != {}

proc initTransform2d(translation: Vec2): Transform2d =
  Transform2d(
    world: mat2d(),
    translation: translation,
    rotation: 0.Rad,
    scale: vec2(1, 1),
    flags: {Dirty, Fresh}
  )

proc initHierarchy: Hierarchy =
  Hierarchy(
    head: NoNodeIdx,
    prev: NoNodeIdx,
    next: NoNodeIdx,
    parent: NoNodeIdx
  )

proc initPrevious: Previous =
  Previous(
    position: point2(0, 0),
    rotation: 0.Rad,
    scale: vec2(1, 1)
  )

proc parent*(game: Game; idx: NodeIdx): NodeIdx =
  template hierarchy: untyped = game.hierarchies[idx.int]
  result = hierarchy.parent

proc firstChild*(game: Game; idx: NodeIdx): NodeIdx =
  template hierarchy: untyped = game.hierarchies[idx.int]
  result = hierarchy.head

proc nextSibling*(game: Game; idx: NodeIdx): NodeIdx =
  template hierarchy: untyped = game.hierarchies[idx.int]
  result = hierarchy.next

proc prependChild(game: var Game; parent, child: NodeIdx) =
  template childHierarchy: untyped = game.hierarchies[child.int]
  template parentHierarchy: untyped = game.hierarchies[parent.int]
  let head = parentHierarchy.head

  childHierarchy.parent = parent
  childHierarchy.prev = NoNodeIdx
  childHierarchy.next = head
  if head != NoNodeIdx:
    game.hierarchies[head.int].prev = child
  parentHierarchy.head = child

proc removeNode(game: var Game; node: NodeIdx) =
  template hierarchy: untyped = game.hierarchies[node.int]
  let parent = hierarchy.parent
  let prev = hierarchy.prev
  let next = hierarchy.next
  let head = hierarchy.head

  if parent != NoNodeIdx and game.hierarchies[parent.int].head == node:
    game.hierarchies[parent.int].head = next
  if prev != NoNodeIdx:
    game.hierarchies[prev.int].next = next
  if next != NoNodeIdx:
    game.hierarchies[next.int].prev = prev

  hierarchy = Hierarchy(
    head: head,
    prev: NoNodeIdx,
    next: NoNodeIdx,
    parent: NoNodeIdx
  )

proc allocNode*(game: var Game; translation: Vec2; parent = NoNodeIdx): NodeIdx =
  if game.freeNodes.len > 0:
    result = NodeIdx(game.freeNodes.pop())
    game.transforms[result.int] = initTransform2d(translation)
    game.hierarchies[result.int] = initHierarchy()
    game.previouss[result.int] = initPrevious()
  else:
    result = NodeIdx(game.transforms.len.int32)
    game.transforms.add(initTransform2d(translation))
    game.hierarchies.add(initHierarchy())
    game.previouss.add(initPrevious())

  if parent != NoNodeIdx:
    game.prependChild(parent, result)

proc freeNode*(game: var Game; idx: NodeIdx) =
  if idx == NoNodeIdx:
    return

  game.removeNode(idx)
  game.freeNodes.add(idx.int32)

proc markDirty*(game: var Game; idx: NodeIdx) =
  if idx != NoNodeIdx:
    template transform: untyped = game.transforms[idx.int]
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

proc ballCount*(game: Game): int {.inline.} =
  game.balls.len

proc brickCount*(game: Game): int {.inline.} =
  game.bricks.len

proc particleCount*(game: Game): int {.inline.} =
  game.particles.len

proc trailCount*(game: Game): int {.inline.} =
  game.trails.len

proc addCollide*(game: var Game; value: sink Collide): CollideIdx =
  result = CollideIdx(game.collides.len.int32)
  game.collides.add(value)

proc addDraw*(game: var Game; value: sink Draw2d): Draw2dIdx =
  result = Draw2dIdx(game.draws.len.int32)
  game.draws.add(value)

proc addFade*(game: var Game; value: sink Fade): FadeIdx =
  result = FadeIdx(game.fades.len.int32)
  game.fades.add(value)

proc addMove*(game: var Game; value: sink Move): MoveIdx =
  result = MoveIdx(game.moves.len.int32)
  game.moves.add(value)

proc addShake*(game: var Game; value: sink Shake): ShakeIdx =
  result = ShakeIdx(game.shakes.len.int32)
  game.shakes.add(value)

proc deleteBall*(game: var Game; idx: BallIdx) =
  let i = idx.int
  let ball = game.balls[i]
  game.freeNode(ball.node)
  game.balls.del(i)

proc deleteBrick*(game: var Game; idx: BrickIdx) =
  let i = idx.int
  let brick = game.bricks[i]
  game.freeNode(brick.node)
  game.bricks.del(i)

proc deleteParticle*(game: var Game; idx: ParticleIdx) =
  let i = idx.int
  let particle = game.particles[i]
  game.freeNode(particle.node)
  game.particles.del(i)

proc deleteTrail*(game: var Game; idx: TrailIdx) =
  let i = idx.int
  let trail = game.trails[i]
  game.freeNode(trail.node)
  game.trails.del(i)
