import
  std / [random, monotimes, os],
  breakout / [sdlpriv, heaparrays, gametypes, blueprints, slottables, utils],
  breakout / systems / [collide, controlball, controlbrick, controlpaddle, draw2d,
      fade, move, shake, transform2d, handleevents]

proc initGame*(windowWidth, windowHeight: int32): Game =
  let sdlContext = sdlInit(InitVideo or InitEvents)
  let window = newWindow("Breakout", SdlWindowPosCentered,
      SdlWindowPosCentered, windowWidth, windowHeight, SdlWindowShown)

  let renderer = newRenderer(window, -1, RendererAccelerated or RendererPresentVsync)

  let world = World(
    signature: initSlotTableOfCap[set[HasComponent]](maxEntities),

    collide: initArray[Collide](),
    draw2d: initArray[Draw2d](),
    fade: initArray[Fade](),
    hierarchy: initArray[Hierarchy](),
    move: initArray[Move](),
    previous: initArray[Previous](),
    transform: initArray[Transform2d]()
  )

  result = Game(
    world: world,
    #snapshot: initSnapHandler(),

    camera: invalidId,
    isRunning: true,
    windowWidth: windowWidth,
    windowHeight: windowHeight,

    renderer: renderer,
    window: window,
    sdlContext: sdlContext,

    clearColor: [0'u8, 0, 0, 255]
  )

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
    targetFrameRate = 60 # desired frames per second
    targetFrameTime = 1_000_000_000 div targetFrameRate # desired nanosecs per frame

  var
    lastTime = getMonoTime().ticks
    accumulator = 0'i64

  while true:
    handleEvents(game)
    #persist(game)
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
      # use interpolation to render the game state at a fraction of a time step
      game.render(accumulator.float32 / skippedTicks.float32)
      # calculate the ideal sleep time based on the target frame rate and the actual frame time
      let frameTime = getMonoTime().ticks - now
      let sleepTime = (targetFrameTime - frameTime) div 1_000_000
      if sleepTime > 0:
        sleep(sleepTime)

proc main =
  randomize()
  var game = initGame(740, 555)
  # Restore previous snapshot of the World
  #if snapExists(game.snapshot):
    #restore(game)
  #else:
  createScene(game)

  run(game)

main()
