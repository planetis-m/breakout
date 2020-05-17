import options, sdl_private, vmath

const
   MaxEntities* = 10_000

type
   HasComponent* = enum
      HasCollide,
      HasControlBall,
      HasControlBrick,
      HasControlPaddle,
      HasDraw2d,
      HasFade,
      HasHierarchy,
      HasMove,
      HasPrevious,
      HasShake,
      HasTransform2d

   Collision* = object
      entity*: int
      hit*: Vec2

   Collide* = object
      entity*: int
      size*: Vec2
      min*, max*: Vec2
      center*: Vec2
      collision*: Option[Collision]

   ControlBall* = object
      direction*: Vec2

   Draw2d* = object
      width*, height*: int32
      color*: array[4, uint8]

   Fade* = object
      step*: float32

   Hierarchy* = object
      head*: int        # the entity identifier of the first child, if any.
      prev*, next*: int # the prev/next sibling in the list of children for the parent.
      parent*: int      # the entity identifier of the parent, if any.

   Move* = object
      direction*: Vec2
      speed*: float32

   Previous* = object
      world*: Mat2d

   Shake* = object
      duration*: float32
      strength*: float32

   Transform2d* = object
      world*: Mat2d      # Matrix relative to the world
      self*: Mat2d       # World to self matrix
      translation*: Vec2 # local translation relative to the parent
      rotation*: float32 # local rotation relative to the parent
      scale*: Vec2       # local scale relative to the parent
      dirty*: bool

   Game* = object
      running*: bool
      world*: seq[set[HasComponent]]
      camera*: int

      windowWidth*, windowHeight*: int

      canvas*: Canvas
      eventPump*: EventPump

      clearColor*: array[4, uint8]
      inputState*: array[ArrowLeft..ArrowRight, bool]

      collide*: seq[Collide]
      controlBall*: seq[ControlBall]
      draw2d*: seq[Draw2d]
      fade*: seq[Fade]
      hierarchy*: seq[Hierarchy]
      move*: seq[Move]
      previous*: seq[Previous]
      shake*: seq[Shake]
      transform*: seq[Transform2d]
