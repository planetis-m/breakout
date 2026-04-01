import raylib, vmath

type
  Input* = enum
    Right, Left

  TransformFlag* = enum
    Dirty, Fresh, HasPrevious

  NodeIdx* = distinct int32
  BallIdx* = distinct int32
  BrickIdx* = distinct int32
  ParticleIdx* = distinct int32
  TrailIdx* = distinct int32
  CollideIdx* = distinct int32
  Draw2dIdx* = distinct int32
  FadeIdx* = distinct int32
  MoveIdx* = distinct int32
  ShakeIdx* = distinct int32

  Collision* = object
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

  Camera* = object
    node*: NodeIdx
    shake*: ShakeIdx

  Paddle* = object
    node*: NodeIdx
    collide*: CollideIdx
    draw*: Draw2dIdx
    move*: MoveIdx

  Ball* = object
    node*: NodeIdx
    collide*: CollideIdx
    draw*: Draw2dIdx
    move*: MoveIdx

  Brick* = object
    node*: NodeIdx
    collide*: CollideIdx
    draw*: Draw2dIdx
    fade*: FadeIdx

  Particle* = object
    node*: NodeIdx
    draw*: Draw2dIdx
    fade*: FadeIdx
    move*: MoveIdx

  Trail* = object
    node*: NodeIdx
    draw*: Draw2dIdx
    fade*: FadeIdx

  Game* = object
    camera*: Camera
    paddle*: Paddle
    balls*: seq[Ball]
    bricks*: seq[Brick]
    particles*: seq[Particle]
    trails*: seq[Trail]

    collides*: seq[Collide]
    draws*: seq[Draw2d]
    fades*: seq[Fade]
    moves*: seq[Move]
    shakes*: seq[Shake]

    nodes*: seq[TransformNode]
    freeNodes*: seq[int32]

    inputState*: array[Input, bool]
    clearColor*: array[4, uint8]

    isRunning*: bool
    windowWidth*, windowHeight*: int32
    tickId*: int

    raylib*: RaylibContext
