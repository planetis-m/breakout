import sdl_private, vmath

const
   MaxEntities* = 10_000

type
   HasComponent* = enum
      HasClearColor,
      HasCollide,
      HasControlBall,
      HasControlBrick,
      HasControlPaddle,
      HasDraw2d,
      HasFade,
      HasHierarchy,
      HasInputState,
      HasMove,
      HasPrevious,
      HasShake,
      HasTransform2d

   Entity* = int32

   Collision* = object
      entity*: Entity
      hit*: Vec2

   Collide* = object
      entity*: Entity
      size*: Vec2
      min*, max*: Vec2
      center*: Vec2
      collision*: Collision

   ControlBall* = object
      direction*: Vec2

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
      camera*: Entity

      windowWidth*, windowHeight*: int32

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
