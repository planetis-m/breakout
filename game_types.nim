import sdl_private, vmath, registry, storage, fusion/smartptrs

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

      collide*: seq[Collide]
      draw2d*: seq[Draw2d]
      fade*: seq[Fade]
      hierarchy*: seq[Hierarchy]
      move*: seq[Move]
      previous*: seq[Previous]
      shake*: UniquePtr[Shake]
      transform*: seq[Transform2d]

   Game* = object
      world*: World

      windowWidth*, windowHeight*: int32
      isRunning*: bool
      tickId*: int

      renderer*: Renderer
      window*: Window
      sdlContext*: SdlContext

      camera*: Entity
      toDelete*: seq[Entity]
      inputState*: array[Input, bool]
      clearColor*: array[4, uint8]
