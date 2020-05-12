import macros, math, vmath, game_types

proc mixCollide(game: var Game, entity: int, size = vec2(0, 0)) =
   game.world[entity].incl HasCollide
   game.collide[entity] = Collide(entity: entity, size: size)

proc mixControlBall(game: var Game, entity: int, angle = Pi * 0.33) =
   game.world[entity].incl HasControlBall
   game.controlBall[entity] = ControlBall(direction: vec2(cos(angle), sin(angle)))

proc mixControlBrick(game: var Game, entity: int) =
   game.world[entity].incl HasControlBrick

proc mixControlPaddle(game: var Game, entity: int) =
   game.world[entity].incl HasControlPaddle

proc mixDraw2d(game: var Game, entity: int, width, height = 100,
      color = [255'u8, 0, 255, 255]) =
   game.world[entity].incl HasDraw2d
   game.draw2d[entity] = Draw2d(width: width, height: height, color: color)

proc mixFade(game: var Game, entity: int, step = 0.0) =
   game.world[entity].incl HasFade
   game.fade[entity] = Fade(step: step)

proc mixHierarchy(game: var Game, entity: int, parent = -1) =
   game.world[entity].incl HasHierarchy
   if parent != -1: prepend(game, parent, entity)

proc mixMove(game: var Game, entity: int, direction = vec2(0, 0), speed = 100) =
   game.world[entity].incl HasMove
   game.move[entity] = Move(direction: direction, speed: speed)

proc mixShake(game: var Game, entity: int, duration = 1.0, strength = 0.0) =
   game.world[entity].incl HasShake
   game.shake[entity] = Shake(duration: duration, strength: strength)

proc mixTransform2d(game: var Game, entity: int, translation = vec2(0, 0),
      rotation = 0.0, scale = vec2(1, 1)) =
   game.world[entity].incl HasTransform2d
   game.transform2d[entity] = Transform2D(world: mat2d(), self: mat2d(),
         translation: translation, rotation: rotation, scale: scale, dirty: true)

proc getBall*(game: var Game, parent = game.camera): int =
   let angle = Pi + rand(1.0) * Pi
   result = blueprint:
      translation = Vec(x: x, y: y)
      parent = parent
      with:
         Collide(size: Vec2(x: 20.0, y: 20.0))
         ControlBall(angle: angle)
         Draw2d(width: 20, height: 20, color: [0'u8, 255, 0, 255])
         Move(direction: Vec2(x: 1.0, y: 1.0), speed: 600.0)

proc getBrick*(game: var Game, parent = game.camera, x, y: float32, width, height: int32): int =
   result = blueprint:
      translation = Vec(x: x, y: y)
      parent = parent
      with:
         Collide(size: Vec2(x: width, y: height))
         ControlBlock()
         Draw2d(width: 20, height: 20, color: [255'u8, 255, 0, 255])
         Fade(step: 0.0)

proc getExplosion(game: var Game, parent = game.camera, x, y: float32): int =
   let explosions = 32
   let step = (Pi * 2.0) / explosions
   let fadeStep = 0.05
   result = game.blueprint:
      translation = Vec(x: x, y: y)
      parent = parent
      children:
         for i in 0 ..< explosions:
            blueprint:
               with:
                  Draw2d(width: 20, height: 20, color: [255'u8, 255, 255, 255])
                  Fade(step: fadeStep)
                  Move(direction: Vec2(x: sin(step * i), y: cos(step * i)), speed: 800.0)

proc getPaddle(game: var Game, parent = game.camera, x, y: float32): int =
   result = game.blueprint:
      translation = Vec(x: x, y: y)
      parent = parent
      with:
         Collide(size: Vec2(x: 100.0, y: 20.0))
         ControlPaddle()
         Draw2d(width: 100, height: 20, color: [255'u8, 0, 0, 255])
         Move(speed: 600.0)

proc sceneMain*(game: var Game) =
   let columnCount = 10
   let rowCount = 10
   let brickWidth = 50
   let brickHeight = 15
   let margin = 5

   let gridWidth = brickWidth * columnCount + margin * (columnCount - 1)
   let startingX = (game.windowWidth - gridWidth) / 2
   let startingY = 50

   game.camera = game.blueprint:
      with(Shake(duration: 0.0, strength: 20.0))
      children:
         entity(getPaddle(float32(game.windowWidth / 2),
               float32(game.windowHeight - 30)))
         entity(getBall(float32(game.windowWidth / 2),
               float32(game.windowHeight - 60)))

         for row in 0 ..< rowCount:
            let y = startingY + row * (brickHeight + margin) + brickHeight / 2
            for col in 0 ..< columnCount:
               let x = startingX + col * (brickWidth + margin) + brickWidth / 2
               entity(getBrick(x.float32, y.float32, brickWidth, brickHeight))
