import sdl_private, vmath, registry, storage

type
   HasComponent* = enum
      HasClearColor,
      HasCollide,
      HasControlBall,
      HasControlBrick,
      HasControlPaddle,
      HasCurrent,
      HasDirty,
      HasDraw2d,
      HasFade,
      HasHierarchy,
      HasInputState,
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

   Current* = object
      world*: Mat2d      # Matrix relative to the world
      origin*: Point2    # origin relative to the world
      rotation*: float32 # rotation relative to the world
      scale*: Vec2       # scale relative to the world

   Draw2d* = object
      width*, height*: int32
      color*: array[4, uint8]

   Fade* = object
      step*: float32

   Hierarchy* = object
      head*: Entity   # the entity identifier of the first child, if any.
      next*: Entity   # the next sibling in the list of children for the parent.
      parent*: Entity # the entity identifier of the parent, if any.

   Move* = object
      direction*: Vec2
      speed*: float32

   Previous* = object
      origin*: Point2    # origin at the previous frame
      rotation*: float32 # rotation at the previous frame
      scale*: Vec2       # scale at the previous frame

   Shake* = object
      duration*: float32
      strength*: float32

   Transform2d* = object
      translation*: Vec2 # local translation relative to the parent
      rotation*: float32 # local rotation relative to the parent
      scale*: Vec2       # local scale relative to the parent

   Game* = object
      world*: Storage[set[HasComponent]]
      entities*: Registry
      camera*: Entity
      isRunning*: bool

      windowWidth*, windowHeight*: int32

      canvas*: Canvas
      eventPump*: EventPump

      clearColor*: array[4, uint8]
      inputState*: array[ArrowLeft..ArrowRight, bool]

      collide*: seq[Collide]
      current*: seq[Current]
      draw2d*: seq[Draw2d]
      fade*: seq[Fade]
      hierarchy*: seq[Hierarchy]
      move*: seq[Move]
      previous*: seq[Previous]
      shake*: seq[Shake]
      transform*: seq[Transform2d]
