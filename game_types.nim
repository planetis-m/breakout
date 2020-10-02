import sdl2, vmath, registry, storage

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

   ShakePtr = object
      impl*: ptr Shake
   Shake* = object
      duration*: float32
      strength*: float32

   Transform2d* = object
      world*: Mat2d      # Matrix relative to the world
      translation*: Vec2 # local translation relative to the parent
      rotation*: Rad     # local rotation relative to the parent
      scale*: Vec2       # local scale relative to the parent

   Game* = object
      world*: Storage[set[HasComponent]]
      entities*: Registry
      toDelete*: seq[Entity]
      camera*: Entity
      isRunning*: bool

      windowWidth*, windowHeight*: int32

      window*: WindowPtr
      renderer*: RendererPtr

      clearColor*: array[4, uint8]
      inputState*: array[Right..Left, bool]

      collide*: seq[Collide]
      draw2d*: seq[Draw2d]
      fade*: seq[Fade]
      hierarchy*: seq[Hierarchy]
      move*: seq[Move]
      previous*: seq[Previous]
      shake*: ShakePtr
      transform*: seq[Transform2d]

proc `=destroy`(x: var ShakePtr) =
   if x.impl != nil:
      dealloc(x.impl)
proc `=`(dest: var ShakePtr; source: ShakePtr) {.error.}
proc newShake*(): ShakePtr =
   result.impl = create(Shake)
