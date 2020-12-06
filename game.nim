import
   std / [random, monotimes], sdlpriv, heaparray,
   gametypes, blueprints, registry, storage, utils,
   systems / [collide, control_ball, control_brick, control_paddle, draw2d,
      fade, move, shake, transform2d, handle_events]

proc initGame*(windowWidth, windowHeight: int32): Game =
   let sdlContext = sdlInit(INIT_VIDEO or INIT_EVENTS)
   let window = newWindow("Breakout", SDL_WINDOWPOS_CENTERED,
         SDL_WINDOWPOS_CENTERED, windowWidth, windowHeight, SDL_WINDOW_SHOWN)

   let renderer = newRenderer(window, -1, Renderer_Accelerated or Renderer_PresentVsync)

   let world = World(
      signature: initStorage[set[HasComponent]](),
      registry: initRegistry(),

      collide: initArray[Collide](),
      draw2d: initArray[Draw2d](),
      fade: initArray[Fade](),
      hierarchy: initArray[Hierarchy](),
      move: initArray[Move](),
      previous: initArray[Previous](),
      transform: initArray[Transform2d]())

   result = Game(
      world: world,

      windowWidth: windowWidth,
      windowHeight: windowHeight,
      isRunning: true,

      renderer: renderer,
      window: window,
      sdlContext: sdlContext,

      clearColor: [0'u8, 0, 0, 255])

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
   # Increment the Game engine tick
   inc(game.tickId)

proc render(game: var Game, intrpl: float32) =
   sysDraw2d(game, intrpl)
   game.renderer.impl.present()

proc run(game: var Game) =
   const
      ticksPerSec = 25
      skippedTicks = 1_000_000_000 div ticksPerSec # to nanosecs per tick
      maxFramesSkipped = 5 # 20% of ticksPerSec

   var
      lastTime = getMonoTime().ticks
      accumulator = 0'i64

   while true:
      handleEvents(game)
      if not game.isRunning: break

      let now = getMonoTime().ticks
      accumulator += now - lastTime
      lastTime = now

      var framesSkipped = 0
      while accumulator >= skippedTicks and framesSkipped < maxFramesSkipped:
         game.update()
         accumulator -= skippedTicks
         framesSkipped.inc

      if framesSkipped > 0:
         game.render(accumulator.float32 / skippedTicks.float32)

proc main =
   randomize()
   var game = initGame(740, 555)

   sceneMain(game)
   game.run()

main()
