import
  std / [random, monotimes],
  breakout / [raylib, heaparrays, gametypes, blueprints, slottables, utils],
  breakout / systems / [collide, controlball, controlbrick, controlpaddle, draw2d,
      fade, move, shake, transform2d, handleevents]

proc initGame*(windowWidth, windowHeight: int32): Game =
  let raylibContext = initRaylib("Breakout", windowWidth, windowHeight)

  let world = World(
    signature: initSlotTableOfCap[set[HasComponent]](MaxEntities),

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
    camera: InvalidId,
    isRunning: true,
    windowWidth: windowWidth,
    windowHeight: windowHeight,

    raylib: raylibContext,

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
  beginDrawing()
  sysDraw2d(game, intrpl)
  endDrawing()
  swapScreenBuffer()

proc run(game: var Game) =
  const
    TickRate = 25
    TickDuration = 1_000_000_000 div TickRate
    MaxTicks = 5 # 20% of tickRate
    FrameRate = 60 # desired frames per second
    FrameDuration = 1_000_000_000 div FrameRate

  var
    lastTime = getMonoTime().ticks
    accumulator = 0'i64

  while true:
    handleEvents(game)
    if not game.isRunning: break

    let now = getMonoTime().ticks
    accumulator += now - lastTime
    lastTime = now

    var ticks = 0
    while accumulator >= TickDuration and ticks < MaxTicks:
      game.update()
      accumulator -= TickDuration
      inc ticks

    let alpha = accumulator.float32 / TickDuration.float32
    game.render(alpha)

    let actualFrameDuration = getMonoTime().ticks - now
    let sleepTime = FrameDuration - actualFrameDuration
    if sleepTime > 0:
      waitTime(sleepTime.float64 / 1_000_000_000.0)

proc main =
  randomize()
  var game = initGame(740, 555)
  createScene(game)

  run(game)

main()
