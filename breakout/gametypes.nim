import raylib, vmath

type
  Input* = enum
    Right, Left

  TransformIdx* = distinct int
  CollideIdx* = distinct int
  Draw2dIdx* = distinct int
  FadeIdx* = distinct int
  MoveIdx* = distinct int

  BallIdx* = distinct int
  BrickIdx* = distinct int
  ParticleIdx* = distinct int
  TrailIdx* = distinct int

  Collision* = object
    hasHit*: bool
    hit*: Vec2

  Collide* = object
    active*: bool
    size*: Vec2
    min*, max*: Point2
    center*: Point2
    collision*: Collision

  Draw2d* = object
    active*: bool
    width*, height*: int32
    color*: array[4, uint8]

  Fade* = object
    active*: bool
    step*: float32

  Move* = object
    active*: bool
    direction*: Vec2
    speed*: float32

  Transform2d* = object
    active*: bool
    world*: Mat2d
    translation*: Vec2
    rotation*: Rad
    scale*: Vec2
    previousPosition*: Point2
    previousRotation*: Rad
    previousScale*: Vec2
    parent*: TransformIdx
    dirty*: bool
    fresh*: bool
    hasPrevious*: bool

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
    alive*: bool
    transform*: TransformIdx
    collide*: CollideIdx
    draw2d*: Draw2dIdx
    move*: MoveIdx

  Brick* = object
    alive*: bool
    transform*: TransformIdx
    collide*: CollideIdx
    draw2d*: Draw2dIdx
    fade*: FadeIdx

  Particle* = object
    alive*: bool
    transform*: TransformIdx
    draw2d*: Draw2dIdx
    fade*: FadeIdx
    move*: MoveIdx

  Trail* = object
    alive*: bool
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
  NoBallIdx* = BallIdx(-1)
  NoBrickIdx* = BrickIdx(-1)
  NoParticleIdx* = ParticleIdx(-1)
  NoTrailIdx* = TrailIdx(-1)

proc `==`*(a, b: TransformIdx): bool {.borrow.}
proc `==`*(a, b: CollideIdx): bool {.borrow.}
proc `==`*(a, b: Draw2dIdx): bool {.borrow.}
proc `==`*(a, b: FadeIdx): bool {.borrow.}
proc `==`*(a, b: MoveIdx): bool {.borrow.}
proc `==`*(a, b: BallIdx): bool {.borrow.}
proc `==`*(a, b: BrickIdx): bool {.borrow.}
proc `==`*(a, b: ParticleIdx): bool {.borrow.}
proc `==`*(a, b: TrailIdx): bool {.borrow.}

proc allocTransform*(game: var Game; translation = vec2(0, 0); rotation = 0.Rad;
    scale = vec2(1, 1); parent = NoTransformIdx): TransformIdx =
  let value = Transform2d(
    active: true,
    world: mat2d(),
    translation: translation,
    rotation: rotation,
    scale: scale,
    previousPosition: point2(0, 0),
    previousRotation: 0.Rad,
    previousScale: vec2(1, 1),
    parent: parent,
    dirty: true,
    fresh: true,
    hasPrevious: false
  )
  if game.freeTransforms.len > 0:
    result = game.freeTransforms.pop()
    game.transforms[result.int] = value
  else:
    result = TransformIdx(game.transforms.len)
    game.transforms.add(value)

proc freeTransform*(game: var Game; idx: TransformIdx) =
  if idx != NoTransformIdx:
    game.transforms[idx.int].active = false
    game.freeTransforms.add(idx)

proc allocCollide*(game: var Game; size = vec2(0, 0)): CollideIdx =
  let value = Collide(
    active: true,
    size: size,
    min: point2(0, 0),
    max: point2(0, 0),
    center: point2(0, 0),
    collision: Collision(hasHit: false, hit: vec2(0, 0))
  )
  if game.freeColliders.len > 0:
    result = game.freeColliders.pop()
    game.colliders[result.int] = value
  else:
    result = CollideIdx(game.colliders.len)
    game.colliders.add(value)

proc freeCollide*(game: var Game; idx: CollideIdx) =
  if idx != NoCollideIdx:
    game.colliders[idx.int].active = false
    game.freeColliders.add(idx)

proc allocDraw2d*(game: var Game; width, height: int32;
    color: array[4, uint8]): Draw2dIdx =
  let value = Draw2d(active: true, width: width, height: height, color: color)
  if game.freeDrawables.len > 0:
    result = game.freeDrawables.pop()
    game.drawables[result.int] = value
  else:
    result = Draw2dIdx(game.drawables.len)
    game.drawables.add(value)

proc freeDraw2d*(game: var Game; idx: Draw2dIdx) =
  if idx != NoDraw2dIdx:
    game.drawables[idx.int].active = false
    game.freeDrawables.add(idx)

proc allocFade*(game: var Game; step = 0'f32): FadeIdx =
  let value = Fade(active: true, step: step)
  if game.freeFades.len > 0:
    result = game.freeFades.pop()
    game.fades[result.int] = value
  else:
    result = FadeIdx(game.fades.len)
    game.fades.add(value)

proc freeFade*(game: var Game; idx: FadeIdx) =
  if idx != NoFadeIdx:
    game.fades[idx.int].active = false
    game.freeFades.add(idx)

proc allocMove*(game: var Game; direction = vec2(0, 0); speed = 10'f32): MoveIdx =
  let value = Move(active: true, direction: direction, speed: speed)
  if game.freeMoves.len > 0:
    result = game.freeMoves.pop()
    game.moves[result.int] = value
  else:
    result = MoveIdx(game.moves.len)
    game.moves.add(value)

proc freeMove*(game: var Game; idx: MoveIdx) =
  if idx != NoMoveIdx:
    game.moves[idx.int].active = false
    game.freeMoves.add(idx)

proc markDirty*(game: var Game; idx: TransformIdx) =
  if idx != NoTransformIdx:
    game.transforms[idx.int].dirty = true
