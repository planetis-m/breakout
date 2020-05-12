import math, random, times, monotimes, sdl, game_types, scene_main
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

proc update*(self: var Game, delta: float32) =
   sysControlBall(self, delta)
   sysControlBrick(self, delta)
   sysControlPaddle(self, delta)
   sysShake(self, delta)
   sysFade(self, delta)
   sysMove(self, delta)
   sysTransform2d(self, delta)
   sysCollide(self, delta)
   sysDraw2d(self, delta)
   sysFramerate(self, delta)

proc start*(self: var Game) =
   var lastTime = getMonoTime()
   block running:
      while true:
         for event in game.eventPump.poll():
            if event.kind == QuitEvent or (event.kind == KeyDown and
                  event.scancode == Escape):
               break running
            elif event.kind == KeyDown and not event.repeat:
               case event.scancode
               of ArrowLeft, KeyA:
                  self.inputState[ArrowLeft] = true
               of ArrowRight, KeyD:
                  self.inputState[ArrowRight] = true
            elif event.kind == KeyUp and not event.repeat:
               case event.scancode
               of ArrowLeft, KeyA:
                  self.inputState[ArrowLeft] = false
               of ArrowRight, KeyD:
                  self.inputState[ArrowRight] = false

         let now = getMonoTime()

         self.update(inMilliseconds(now - lastTime).float32 / 1000.0)

         lastTime = now
         self.canvas.present()

proc main =
   randomize()
   var game = initGame(640, 480)

   sceneMain(game)
   game.start()

main()
