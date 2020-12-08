import random, math, dsl, vmath, gametypes, registry

proc getBall*(world: var World, parent: Entity, x, y: float32): Entity =
  let angle = Pi + rand(1.0) * Pi
  result = world.addBlueprint:
    translation = Vec2(x: x, y: y)
    parent = parent
    with:
      Collide(size: Vec2(x: 20.0, y: 20.0))
      ControlBall()
      Draw2d(width: 20, height: 20, color: [0'u8, 255, 0, 255])
      Move(direction: Vec2(x: cos(angle), y: sin(angle)), speed: 14.0)

proc getBrick*(world: var World, parent: Entity, x, y: float32, width, height: int32): Entity =
  result = world.addBlueprint:
    translation = Vec2(x: x, y: y)
    parent = parent
    with:
      Collide(size: Vec2(x: width.float32, y: height.float32))
      ControlBrick()
      Draw2d(width: width, height: height, color: [255'u8, 255, 0, 255])
      Fade(step: 0.0)

proc getExplosion*(world: var World, parent: Entity, x, y: float32): Entity =
  let explosions = 32
  let step = (Pi * 2.0) / explosions.float
  let fadeStep = 0.05
  result = world.addBlueprint:
    translation = Vec2(x: x, y: y)
    parent = parent
    children:
      for i in 0 ..< explosions:
        blueprint:
          with:
            Draw2d(width: 20, height: 20, color: [255'u8, 255, 255, 255])
            Fade(step: fadeStep)
            Move(direction: Vec2(x: sin(step * i.float), y: cos(step * i.float)), speed: 20.0)

proc getPaddle*(world: var World, parent: Entity, x, y: float32): Entity =
  result = world.addBlueprint:
    translation = Vec2(x: x, y: y)
    parent = parent
    with:
      Collide(size: Vec2(x: 100.0, y: 20.0))
      ControlPaddle()
      Draw2d(width: 100, height: 20, color: [255'u8, 0, 0, 255])
      Move(speed: 20.0)

proc sceneMain*(game: var Game) =
  let columnCount = 10
  let rowCount = 10
  let brickWidth = 50
  let brickHeight = 15
  let margin = 5

  let gridWidth = brickWidth * columnCount + margin * (columnCount - 1)
  let startingX = (game.windowWidth - gridWidth) div 2
  let startingY = 50

  game.camera = game.world.addBlueprint:
    with(Shake(duration: 0.0, strength: 10.0))
    children:
      entity getPaddle(float32(game.windowWidth / 2),
            float32(game.windowHeight - 30))
      entity getBall(float32(game.windowWidth / 2),
            float32(game.windowHeight - 60))

      for row in 0 ..< rowCount:
        let y = startingY + row * (brickHeight + margin) + brickHeight div 2
        for col in 0 ..< columnCount:
          let x = startingX + col * (brickWidth + margin) + brickWidth div 2
          entity getBrick(x.float32, y.float32, brickWidth.int32, brickHeight.int32)
