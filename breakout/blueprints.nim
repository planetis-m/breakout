import std/math
import gametypes, procgen, vmath

proc createBall*(game: var Game; x, y: float32; seed: uint32) =
  let angle = angleFromSeed(seed)
  let node = game.allocNode(vec2(x, y), game.camera.node)
  game.balls.add(Ball(
    node: node,
    collide: initCollide(vec2(20, 20)),
    draw: Draw2d(width: 20, height: 20, color: [0'u8, 255, 0, 255]),
    move: Move(direction: Vec2(x: cos(angle), y: sin(angle)), speed: 14)
  ))

proc createBrick*(game: var Game; x, y: float32; width, height: int32) =
  let node = game.allocNode(vec2(x, y), game.camera.node)
  game.bricks.add(Brick(
    node: node,
    collide: initCollide(vec2(width.float32, height.float32)),
    draw: Draw2d(width: width, height: height, color: [255'u8, 255, 0, 255]),
    fade: Fade(step: 0),
    dead: false
  ))

proc createExplosion*(game: var Game; x, y: float32) =
  let explosions = 32
  let step = TAU / explosions.float
  let fadeStep = 0.05

  for i in 0..<explosions:
    let node = game.allocNode(vec2(x, y), game.camera.node)
    game.particles.add(Particle(
      node: node,
      draw: Draw2d(width: 20, height: 20, color: [255'u8, 255, 255, 255]),
      fade: Fade(step: fadeStep),
      move: Move(
        direction: Vec2(x: sin(step * i.float32), y: cos(step * i.float32)),
        speed: 20
      ),
      dead: false
    ))

proc createTrail*(game: var Game; x, y: float32) =
  let node = game.allocNode(vec2(x, y), game.camera.node)
  game.trails.add(Trail(
    node: node,
    draw: Draw2d(width: 20, height: 20, color: [0'u8, 255, 0, 255]),
    fade: Fade(step: 0.05),
    dead: false
  ))

proc createPaddle*(game: var Game; x, y: float32) =
  let node = game.allocNode(vec2(x, y), game.camera.node)
  game.paddle = Paddle(
    active: true,
    node: node,
    collide: initCollide(vec2(100, 20)),
    draw: Draw2d(width: 100, height: 20, color: [255'u8, 0, 0, 255]),
    move: Move(direction: vec2(0, 0), speed: 20)
  )

proc createScene*(game: var Game; scale: BenchScale) =
  let columnCount = scale.columns
  let rowCount = scale.rows
  let brickWidth = 50
  let brickHeight = 15
  let margin = 5

  let gridWidth = brickWidth * columnCount + margin * (columnCount - 1)
  let startingX = (game.windowWidth - gridWidth) div 2
  let startingY = 50

  game.camera = Camera(
    node: game.allocNode(vec2(0, 0)),
    shake: Shake(duration: 0, strength: 10)
  )

  game.createPaddle(
    float32(game.windowWidth / 2),
    float32(game.windowHeight - 30)
  )
  game.createBall(
    float32(game.windowWidth / 2),
    float32(game.windowHeight - 60),
    eventSeed(1'u32, 0, float32(game.windowWidth / 2),
      float32(game.windowHeight - 60))
  )

  for row in 0..<rowCount:
    let y = startingY + row * (brickHeight + margin) + brickHeight div 2
    for col in 0..<columnCount:
      let x = startingX + col * (brickWidth + margin) + brickWidth div 2
      game.createBrick(x.float32, y.float32, brickWidth.int32, brickHeight.int32)
