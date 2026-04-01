import std/[random, math], mixins, utils, vmath, gametypes

proc createBall*(world: var World, parent: Entity, x, y: float32): Entity =
  let angle = Pi.float32 + rand(1.0'f32) * Pi.float32
  let entity = createEntity(world)
  mixTransform2d(world, entity, mat2d(), Vec2(x: x, y: y), Rad(0), vec2(1, 1), parent)
  mixCollide(world, entity, Vec2(x: 20.0, y: 20.0))
  mixControlBall(world, entity)
  mixDraw2d(world, entity, 20, 20, [0'u8, 255, 0, 255])
  mixMove(world, entity, Vec2(x: cos(angle), y: sin(angle)), 14)
  result = entity

proc createBrick*(world: var World, parent: Entity, x, y: float32, width, height: int32): Entity =
  let entity = createEntity(world)
  mixTransform2d(world, entity, mat2d(), Vec2(x: x, y: y), Rad(0), vec2(1, 1), parent)
  mixCollide(world, entity, Vec2(x: width.float32, y: height.float32))
  mixControlBrick(world, entity)
  mixDraw2d(world, entity, width, height, [255'u8, 255, 0, 255])
  mixFade(world, entity, 0.0)
  result = entity

proc createExplosion*(world: var World, parent: Entity, x, y: float32): Entity =
  let explosions = 32
  let step = Tau / explosions.float
  let fadeStep = 0.05
  let explosion = createEntity(world)
  mixTransform2d(world, explosion, mat2d(), Vec2(x: x, y: y), Rad(0), vec2(1, 1), parent)
  for i in 0 ..< explosions:
    let particle = createEntity(world)
    mixTransform2d(world, particle, mat2d(), vec2(0, 0), Rad(0), vec2(1, 1), explosion)
    mixDraw2d(world, particle, 20, 20, [255'u8, 255, 255, 255])
    mixFade(world, particle, fadeStep)
    mixMove(world, particle, Vec2(x: sin(step * i.float32), y: cos(step * i.float32)), 20)
  result = explosion

proc createPaddle*(world: var World, parent: Entity, x, y: float32): Entity =
  let entity = createEntity(world)
  mixTransform2d(world, entity, mat2d(), Vec2(x: x, y: y), Rad(0), vec2(1, 1), parent)
  mixCollide(world, entity, Vec2(x: 100, y: 20))
  mixControlPaddle(world, entity)
  mixDraw2d(world, entity, 100, 20, [255'u8, 0, 0, 255])
  mixMove(world, entity, vec2(0, 0), 20)
  result = entity

proc createScene*(game: var Game) =
  let columnCount = 10
  let rowCount = 10
  let brickWidth = 50
  let brickHeight = 15
  let margin = 5

  let gridWidth = brickWidth * columnCount + margin * (columnCount - 1)
  let startingX = (game.windowWidth - gridWidth) div 2
  let startingY = 50

  let camera = createEntity(game.world)
  mixTransform2d(game.world, camera, mat2d(), vec2(0, 0), Rad(0), vec2(1, 1), InvalidId)
  mixShake(game.world, camera, 0, 10)
  discard createPaddle(game.world, camera, float32(game.windowWidth / 2), float32(game.windowHeight - 30))
  discard createBall(game.world, camera, float32(game.windowWidth / 2), float32(game.windowHeight - 60))
  for row in 0 ..< rowCount:
    let y = startingY + row * (brickHeight + margin) + brickHeight div 2
    for col in 0 ..< columnCount:
      let x = startingX + col * (brickWidth + margin) + brickWidth div 2
      discard createBrick(game.world, camera, x.float32, y.float32, brickWidth.int32, brickHeight.int32)
  game.camera = camera
