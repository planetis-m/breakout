import std/[math, random]
import gamecore, raylib, vmath

proc createBall*(game: var Game; x, y: float32; parent = NoNodeIdx) =
  let angle = PI.float32 + rand(1.0'f32) * PI.float32
  let node = game.allocNode(vec2(x, y), parent)
  game.balls.add(Ball(
    node: node,
    collide: initCollide(vec2(20, 20)),
    draw: Draw2d(width: 20, height: 20, color: Color(r: 0, g: 255, b: 0, a: 255)),
    move: Move(direction: Vec2(x: cos(angle), y: sin(angle)), speed: 14)
  ))

proc createBrick*(game: var Game; x, y: float32; width, height: int32;
    parent = NoNodeIdx) =
  let node = game.allocNode(vec2(x, y), parent)
  game.bricks.add(Brick(
    node: node,
    collide: initCollide(vec2(width.float32, height.float32)),
    draw: Draw2d(width: width, height: height, color: Color(r: 255, g: 255, b: 0, a: 255)),
    fade: Fade(step: 0)
  ))

proc createExplosion*(game: var Game; x, y: float32; parent = NoNodeIdx) =
  let explosions = 32
  let step = TAU / explosions.float
  let fadeStep = 0.05

  for i in 0..<explosions:
    let node = game.allocNode(vec2(x, y), parent)
    game.particles.add(Particle(
      node: node,
      draw: Draw2d(width: 20, height: 20, color: Color(r: 255, g: 255, b: 255, a: 255)),
      fade: Fade(step: fadeStep),
      move: Move(
        direction: Vec2(x: sin(step * i.float32), y: cos(step * i.float32)),
        speed: 20
      )
    ))

proc createTrail*(game: var Game; x, y: float32; parent = NoNodeIdx) =
  let node = game.allocNode(vec2(x, y), parent)
  game.trails.add(Trail(
    node: node,
    draw: Draw2d(width: 20, height: 20, color: Color(r: 0, g: 255, b: 0, a: 255)),
    fade: Fade(step: 0.05)
  ))

proc createPaddle*(game: var Game; x, y: float32; parent = NoNodeIdx) =
  let node = game.allocNode(vec2(x, y), parent)
  game.paddle = Paddle(
    node: node,
    collide: initCollide(vec2(100, 20)),
    draw: Draw2d(width: 100, height: 20, color: Color(r: 255, g: 0, b: 0, a: 255)),
    move: Move(direction: vec2(0, 0), speed: 20)
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

  let cameraNode = game.allocNode(vec2(0, 0))
  game.camera = Camera(
    node: cameraNode,
    shake: Shake(duration: 0, strength: 10)
  )

  game.createPaddle(float32(game.windowWidth / 2), float32(game.windowHeight - 30), cameraNode)
  game.createBall(float32(game.windowWidth / 2), float32(game.windowHeight - 60), cameraNode)

  for row in 0..<rowCount:
    let y = startingY + row * (brickHeight + margin) + brickHeight div 2
    for col in 0..<columnCount:
      let x = startingX + col * (brickWidth + margin) + brickWidth div 2
      game.createBrick(x.float32, y.float32, brickWidth.int32, brickHeight.int32, cameraNode)
