import sdlpriv, vmath, registry, storage, heaparray, fusion/smartptrs

type
  Input* = enum
    Right, Left

  HasComponent* = enum
    HasCollide,
    HasControlBall,
    HasControlBrick,
    HasControlPaddle,
    HasDirty,
    HasDraw2d,
    HasFade,
    HasFresh,
    HasHierarchy,
    HasMove,
    HasPrevious,
    HasShake,
    HasTransform2d

  Collision* = object
    other*: Entity
    hit*: Vec2

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

  Hierarchy* = object
    head*: Entity        # the entity identifier of the first child, if any.
    prev*, next*: Entity # the prev/next sibling in the list of children for the parent.
    parent*: Entity      # the entity identifier of the parent, if any.

  Move* = object
    direction*: Vec2
    speed*: float32

  Previous* = object
    position*: Point2 # position at the previous physics state
    rotation*: Rad    # rotation at the previous physics state
    scale*: Vec2      # scale at the previous physics state

  Shake* = object
    duration*: float32
    strength*: float32

  Transform2d* = object
    world*: Mat2d      # Matrix relative to the world
    translation*: Vec2 # local translation relative to the parent
    rotation*: Rad     # local rotation relative to the parent
    scale*: Vec2       # local scale relative to the parent

  World* = object
    signature*: Storage[set[HasComponent]]
    registry*: Registry

    collide*: Array[Collide]
    draw2d*: Array[Draw2d]
    fade*: Array[Fade]
    hierarchy*: Array[Hierarchy]
    move*: Array[Move]
    previous*: Array[Previous]
    shake*: UniquePtr[Shake]
    transform*: Array[Transform2d]

  Game* = object
    world*: World

    toDelete*: seq[Entity]
    inputState*: array[Input, bool]
    clearColor*: array[4, uint8]
    camera*: Entity

    isRunning*: bool
    tickId*: int
    windowWidth*, windowHeight*: int32

    renderer*: Renderer
    window*: Window
    sdlContext*: SdlContext
