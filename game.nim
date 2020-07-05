import math, random, monotimes, sdl_private, game_types, blueprints, registry,
      storage
import systems / [collide, control_ball, control_brick, control_paddle, draw2d,
      fade, move, shake, transform2d, handle_events]

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
      isRunning: true,

      windowWidth: windowWidth,
      windowHeight: windowHeight,

      canvas: canvas,
      eventPump: eventPump,

      clearColor: [0'u8, 0, 0, 255],

      collide: newSeq[Collide](maxEntities),
      current: newSeq[Current](maxEntities),
      draw2d: newSeq[Draw2d](maxEntities),
      fade: newSeq[Fade](maxEntities),
      hierarchy: newSeq[Hierarchy](maxEntities),
      move: newSeq[Move](maxEntities),
      previous: newSeq[Previous](maxEntities),
      shake: newSeq[Shake](maxEntities),
      transform: newSeq[Transform2d](maxEntities))

proc update(game: var Game) =
   # The Game engine that consist of these systems
   # Player input and AI
   sysControlBall(game)
   sysControlBrick(game)
   sysControlPaddle(game)
   # Game logic
   sysShake(game)
   sysFade(game)
   # Garbage collection
   cleanup(game)
   # Animation and movement
   sysMove(game)
   sysTransform2d(game)
   # Post-transform logic
   sysCollide(game)

proc render(game: var Game, intrpl: float32) =
   sysIntrpl2d(game, intrpl)
   sysDraw2d(game)
   game.canvas.present()

proc run(game: var Game) =
   const
      ticksPerSec = 25
      skippedTicks = 1_000_000_000 div ticksPerSec # to nanosecs per tick
      maxFramesSkipped = 5 # 20% of ticksPerSec

   var lastTime = getMonoTime().ticks
   while true:
      handleEvents(game)
      if not game.isRunning: break

      let now = getMonoTime().ticks
      var framesSkipped = 0
      while now - lastTime >= skippedTicks and framesSkipped < maxFramesSkipped:
         game.update()
         lastTime += skippedTicks
         framesSkipped.inc

      game.render(float32(now - lastTime) / skippedTicks.float32)

proc main =
   randomize()
   var game = initGame(640, 480)

   sceneMain(game)
   game.run()

main()
