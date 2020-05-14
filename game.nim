import math, random, monotimes, sdl, game_types, scene_main
import systems / [collide, control_ball, control_brick, control_paddle,
   draw2d, fade, framerate, move, shake, transform2d]

proc initGame*(windowWidth, windowHeight: int): Game =
   let sdlContext = sdlInit()
   let videoSubsystem = sdlContext.videoInit()
   let window = videoSubsystem.window("breakout", positionCentered,
         positionCentered, windowWidth, windowHeight, {Shown})

   let canvas = window.intoCanvas({Accelerated, PresentVsync})
   #canvas.setDrawBlendMode(Blend)

   let eventPump = sdlContext.eventInit()

   result = Game(
      running: true,
      world: newSeq[set[HasComponent]](MaxEntities),

      windowWidth: windowWidth,
      windowHeight: windowHeight,

      canvas: canvas,
      eventPump: eventPump,

      clearColor: [0'u8, 0, 0, 255],

      collide: newSeq[Collide](MaxEntities),
      controlBall: newSeq[ControlBall](MaxEntities),
      draw2d: newSeq[Draw2d](MaxEntities),
      fade: newSeq[Fade](MaxEntities),
      hierarchy: newSeq[Hierarchy](MaxEntities),
      move: newSeq[Move](MaxEntities),
      shake: newSeq[Shake](MaxEntities),
      transform: newSeq[Transform2d](MaxEntities))

proc createEntity*(self: var Game): int =
   for i in 0 ..< MaxEntities:
      if self.world[i] == {}:
         return i
   raise newException(ResourceExhaustedError, "No more entities available!")

template `?=`(name, value): bool = (let name = value; name != -1)
proc prependNode*(game: var Game, parentId, entity: int) =
   template hierarchy: untyped = game.hierarchy[entity]
   template parent: untyped = game.hierarchy[parentId]
   template headSibling: untyped = game.hierarchy[headSiblingId]

   hierarchy.prev = -1
   hierarchy.next = parent.head
   if headSiblingId ?= parent.head:
      assert headSibling.prev == -1
      headSibling.prev = entity
   parent.head = entity

proc removeNode*(game: var Game, entity: int) =
   template hierarchy: untyped = game.hierarchy[entity]
   template parent: untyped = game.hierarchy[parentId]
   template nextSibling: untyped = game.hierarchy[nextSiblingId]
   template prevSibling: untyped = game.hierarchy[prevSiblingId]

   let parentId = hierarchy.parent
   if entity == parent.head: parent.head = hierarchy.next
   if nextSiblingId ?= hierarchy.next: nextSibling.prev = hierarchy.prev
   if prevSiblingId ?= hierarchy.prev: prevSibling.next = hierarchy.next

proc delete*(self: var Game, entity: int) =
   if HasHierarchy in game.world[entity]:
      removeNode(game, entity)
   self.world[entity] = {}

proc update*(self: var Game) =
   sysHandleInput(self)
   sysControlBall(self)
   sysControlBrick(self)
   sysControlPaddle(self)
   sysShake(self)
   sysFade(self)
   sysMove(self)
   sysTransform2d(self)
   sysCollide(self)

proc start(self: var Game) =
   const
      ticksPerSec = 25
      skippedTicks = 1_000_000_000 div ticksPerSec # to nanosecs per tick
      maxFramesSkipped = 5 # 20% of ticksPerSec

   var lastTime = getMonoTime().ticks
   while self.running:
      let now = getMonoTime().ticks
      var framesSkipped = 0
      while now - lastTime > skippedTicks and framesSkipped < maxFramesSkipped:
         self.update()
         lastTime += skippedTicks
         framesSkipped.inc

      self.sysDraw2d(float32(now - lastTime) / skippedTicks.float32))
      self.canvas.present()

proc main =
   randomize()
   var game = initGame(640, 480)

   sceneMain(game)
   game.start()

main()
