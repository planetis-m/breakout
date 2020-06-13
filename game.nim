import math, random, monotimes, sdl_private, game_types, blueprints, registry, storage
import systems / [collide, control_ball, control_brick, control_paddle,
      draw2d, fade, handle_input, move, shake, transform2d]

proc initGame*(windowWidth, windowHeight: int32): Game =
   let sdlContext = sdlInit()
   let videoSubsystem = sdlContext.videoInit()
   let window = videoSubsystem.window("breakout", positionCentered,
         positionCentered, windowWidth, windowHeight, {Shown})

   let canvas = window.intoCanvas({Accelerated, PresentVsync})
   #canvas.setDrawBlendMode(Blend)

   let eventPump = sdlContext.eventInit()

   result = Game(
      world: initStorage[set[HasComponent]](maxEntities),
      entities: initRegistry(),
      running: true,

      windowWidth: windowWidth,
      windowHeight: windowHeight,

      canvas: canvas,
      eventPump: eventPump,

      clearColor: [0'u8, 0, 0, 255],

      collide: newSeq[Collide](maxEntities),
      draw2d: newSeq[Draw2d](maxEntities),
      fade: newSeq[Fade](maxEntities),
      hierarchy: newSeq[Hierarchy](maxEntities),
      move: newSeq[Move](maxEntities),
      previous: newSeq[Previous](maxEntities),
      shake: newSeq[Shake](maxEntities),
      transform: newSeq[Transform2d](maxEntities))

proc update(game: var Game) =
   # The Game engine that consist of these systems
   sysHandleInput(game)
   sysControlBall(game)
   sysControlBrick(game)
   sysControlPaddle(game)
   sysShake(game)
   sysFade(game)
   sysMove(game)
   sysTransform2d(game)
   sysCollide(game)

proc render(game: var Game, intrpl: float32) =
   sysDraw2d(game, intrpl)

proc run(game: var Game) =
   const
      ticksPerSec = 25
      skippedTicks = 1_000_000_000 div ticksPerSec # to nanosecs per tick
      maxFramesSkipped = 5 # 20% of ticksPerSec

   var lastTime = getMonoTime().ticks
   block outer:
      while true:
         let now = getMonoTime().ticks
         var framesSkipped = 0
         while now - lastTime > skippedTicks and framesSkipped < maxFramesSkipped:
            game.update()
            if not game.running: break outer
            lastTime += skippedTicks
            framesSkipped.inc

         game.render(float32(now - lastTime) / skippedTicks.float32))
         game.canvas.present()

proc main =
   randomize()
   var game = initGame(640, 480)

   sceneMain(game)
   game.run()

main()
