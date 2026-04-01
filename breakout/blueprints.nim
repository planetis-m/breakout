import std/[math, random], gametypes, vmath

proc createBall*(game: var Game; x, y: float32): BallIdx =
  let angle = PI.float32 + rand(1.0'f32) * PI.float32
  let transform = game.allocTransform(
    translation = vec2(x, y),
    scale = vec2(1, 1),
    parent = game.camera.transform
  )
  let ball = Ball(
    alive: true,
    transform: transform,
    collide: game.allocCollide(vec2(20, 20)),
    draw2d: game.allocDraw2d(20, 20, [0'u8, 255, 0, 255]),
    move: game.allocMove(Vec2(x: cos(angle), y: sin(angle)), 14)
  )
  result = BallIdx(game.balls.len)
  game.balls.add(ball)

proc createBrick*(game: var Game; x, y: float32; width, height: int32): BrickIdx =
  let brick = Brick(
    alive: true,
    transform: game.allocTransform(
      translation = vec2(x, y),
      scale = vec2(1, 1),
      parent = game.camera.transform
    ),
    collide: game.allocCollide(vec2(width.float32, height.float32)),
    draw2d: game.allocDraw2d(width, height, [255'u8, 255, 0, 255]),
    fade: game.allocFade(0)
  )
  result = BrickIdx(game.bricks.len)
  game.bricks.add(brick)

proc createExplosion*(game: var Game; x, y: float32) =
  let explosions = 32
  let step = TAU / explosions.float
  let fadeStep = 0.05
  for i in 0..<explosions:
    let particle = Particle(
      alive: true,
      transform: game.allocTransform(
        translation = vec2(x, y),
        scale = vec2(1, 1),
        parent = game.camera.transform
      ),
      draw2d: game.allocDraw2d(20, 20, [255'u8, 255, 255, 255]),
      fade: game.allocFade(fadeStep),
      move: game.allocMove(
        Vec2(x: sin(step * i.float32), y: cos(step * i.float32)),
        20
      )
    )
    game.particles.add(particle)

proc createTrail*(game: var Game; x, y: float32) =
  let trail = Trail(
    alive: true,
    transform: game.allocTransform(
      translation = vec2(x, y),
      scale = vec2(1, 1),
      parent = game.camera.transform
    ),
    draw2d: game.allocDraw2d(20, 20, [0'u8, 255, 0, 255]),
    fade: game.allocFade(0.05)
  )
  game.trails.add(trail)

proc createPaddle*(game: var Game; x, y: float32) =
  game.paddle = Paddle(
    transform: game.allocTransform(
      translation = vec2(x, y),
      scale = vec2(1, 1),
      parent = game.camera.transform
    ),
    collide: game.allocCollide(vec2(100, 20)),
    draw2d: game.allocDraw2d(100, 20, [255'u8, 0, 0, 255]),
    move: game.allocMove(vec2(0, 0), 20)
  )

proc createScene*(game: var Game) =
  let columnCount = 10
  let rowCount = 10
  let brickWidth = 50
  let brickHeight = 15
  let margin = 5

  let gridWidth = brickWidth * columnCount + margin * (columnCount - 1)
  let startingX = (game.windowWidth - gridWidth) div 2
  let startingY = 50

  game.camera = Camera(
    transform: game.allocTransform(
      translation = vec2(0, 0),
      scale = vec2(1, 1),
      parent = NoTransformIdx
    ),
    shake: Shake(duration: 0, strength: 10)
  )

  game.createPaddle(float32(game.windowWidth / 2), float32(game.windowHeight - 30))
  discard game.createBall(float32(game.windowWidth / 2), float32(game.windowHeight - 60))

  for row in 0..<rowCount:
    let y = startingY + row * (brickHeight + margin) + brickHeight div 2
    for col in 0..<columnCount:
      let x = startingX + col * (brickWidth + margin) + brickWidth div 2
      discard game.createBrick(x.float32, y.float32, brickWidth.int32, brickHeight.int32)
