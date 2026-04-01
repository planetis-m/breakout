import
  std/[monotimes, random],
  breakout/[blueprints, gametypes, raylib],
  breakout/systems/[collide, controlball, controlbrick, controlpaddle, draw2d,
    fade, handleevents, move, shake, transform2d]

proc initGame*(windowWidth, windowHeight: int32): Game =
  let raylibContext = initRaylib("Breakout", windowWidth, windowHeight)

  result = Game(
    isRunning: true,
    windowWidth: windowWidth,
    windowHeight: windowHeight,
    raylib: raylibContext,
    clearColor: [0'u8, 0, 0, 255]
  )

proc update(game: var Game) =
  sysControlBall(game)
  sysControlBrick(game)
  sysControlPaddle(game)
  sysShake(game)
  sysFade(game)
  cleanupDead(game)
  sysMove(game)
  sysTransform2d(game)
  sysCollide(game)
  inc(game.tickId)

proc render(game: var Game; intrpl: float32) =
  beginDrawing()
  sysDraw2d(game, intrpl)
  endDrawing()
  swapScreenBuffer()

proc run(game: var Game) =
  const
    TickRate = 25
    TickDuration = 1_000_000_000 div TickRate
    MaxTicks = 5
    FrameRate = 60
    FrameDuration = 1_000_000_000 div FrameRate

  var
    lastTime = getMonoTime().ticks
    accumulator = 0'i64

  while true:
    handleEvents(game)
    if not game.isRunning:
      break

    let now = getMonoTime().ticks
    accumulator += now - lastTime
    lastTime = now

    var ticks = 0
    while accumulator >= TickDuration and ticks < MaxTicks:
      game.update()
      accumulator -= TickDuration
      inc ticks

    if ticks > 0:
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
