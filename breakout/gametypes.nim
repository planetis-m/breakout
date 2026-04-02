import raylib, vmath

type
  Input* = enum
    Right, Left

  TransformFlag* = enum
    Dirty, Fresh, HasPrevious

  NodeIdx* = distinct int32

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
    color*: Color

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
    shake*: Shake

  Paddle* = object
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

  Particle* = object
    node*: NodeIdx
    draw*: Draw2d
    fade*: Fade
    move*: Move

  Trail* = object
    node*: NodeIdx
    draw*: Draw2d
    fade*: Fade

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
    clearColor*: Color

    isRunning*: bool
    windowWidth*, windowHeight*: int32
    tickId*: int

    raylib*: RaylibContext
