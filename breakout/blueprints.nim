import std/[random, math], builddsl, vmath, gametypes

proc createBall*(world: var World, parent: Entity, x, y: float32): Entity =
  let angle = Pi.float32 + rand(1.0'f32) * Pi.float32
  result = world.build(blueprint):
    with:
      Transform2d(translation: Vec2(x: x, y: y), parent: parent)
      Collide(size: Vec2(x: 20.0, y: 20.0))
      ControlBall()
      Draw2d(width: 20, height: 20, color: [0'u8, 255, 0, 255])
      Move(direction: Vec2(x: cos(angle), y: sin(angle)), speed: 14)

proc createBrick*(world: var World, parent: Entity, x, y: float32, width, height: int32): Entity =
  result = world.build(blueprint):
    with:
      Transform2d(translation: Vec2(x: x, y: y), parent: parent)
      Collide(size: Vec2(x: width.float32, y: height.float32))
      ControlBrick()
      Draw2d(width: width, height: height, color: [255'u8, 255, 0, 255])
      Fade(step: 0.0)

proc createExplosion*(world: var World, parent: Entity, x, y: float32): Entity =
  let explosions = 32
  let step = Tau / explosions.float
  let fadeStep = 0.05
  result = world.build(blueprint(id = explosion)):
    with(Transform2d(translation: Vec2(x: x, y: y), parent: parent))
    children:
      for i in 0 ..< explosions:
        blueprint:
          with:
            Transform2d(parent: explosion)
            Draw2d(width: 20, height: 20, color: [255'u8, 255, 255, 255])
            Fade(step: fadeStep)
            Move(direction: Vec2(x: sin(step * i.float32), y: cos(step * i.float32)), speed: 20)

proc createPaddle*(world: var World, parent: Entity, x, y: float32): Entity =
  result = world.build(blueprint):
    with:
      Transform2d(translation: Vec2(x: x, y: y), parent: parent)
      Collide(size: Vec2(x: 100, y: 20))
      ControlPaddle()
      Draw2d(width: 100, height: 20, color: [255'u8, 0, 0, 255])
      Move(speed: 20)

proc createScene*(game: var Game) =
  let columnCount = 10
  let rowCount = 10
  let brickWidth = 50
  let brickHeight = 15
  let margin = 5

  let gridWidth = brickWidth * columnCount + margin * (columnCount - 1)
  let startingX = (game.windowWidth - gridWidth) div 2
  let startingY = 50

  game.camera = game.world.build(blueprint):
    with:
      Transform2d()
      Shake(duration: 0, strength: 10)
    children:
      createPaddle(float32(game.windowWidth / 2), float32(game.windowHeight - 30))
      createBall(float32(game.windowWidth / 2), float32(game.windowHeight - 60))
      for row in 0 ..< rowCount:
        let y = startingY + row * (brickHeight + margin) + brickHeight div 2
        for col in 0 ..< columnCount:
          let x = startingX + col * (brickWidth + margin) + brickWidth div 2
          createBrick(x.float32, y.float32, brickWidth.int32, brickHeight.int32)
