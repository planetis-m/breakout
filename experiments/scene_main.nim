import math, random, game_types

proc mixCollide(game: var Game, entity: int) =
   game.world[entity].incl HasCollide
   game.collide[entity] = Collide(
      entity: entity,
      size: vec2(0, 0),
      min: vec2(0, 0),
      max: vec2(0, 0),
      center: vec2(0, 0),
      collision: none[Collision]())

proc mixControlBall(game: var Game, entity: int) =
   game.world[entity].incl HasControlBall
   game.controlBall[entity] = ControlBall(
      direction: vec2(0, 0))

proc mixControlBrick(game: var Game, entity: int) =
   game.world[entity].incl HasControlBrick

proc mixControlPaddle(game: var Game, entity: int) =
   game.world[entity].incl HasControlPaddle

proc mixDraw2d(game: var Game, entity: int) =
   game.world[entity].incl HasDraw2d
   game.draw2d[entity] = Draw2d(
      width: 100,
      height: 100,
      color: array[0'u8, 0, 0, 0xFF])

proc mixFade(game: var Game, entity: int) =
   game.world[entity].incl HasFade
   game.fade[entity] = Fade(
      step: 0.0)

proc mixMove(game: var Game, entity: int) =
   game.world[entity].incl HasMove
   game.move[entity] = Move(
      direction: vec2(0, 0),
      speed: 100)

proc mixShake(game: var Game, entity: int) =
   game.world[entity].incl HasShake
   game.shake[entity] = Shake(
      duration: 0.0,
      strength: 20.0)

proc mixTransform2d(game: var Game, entity: int) =
   game.world[entity].incl HasTransform2d
   game.transform2d[entity] = Transform2D(
      world: mat2d(),
      self: mat2d(),
      translation: vec2(0, 0),
      rotation: 0.0,
      scale: vec2(1, 1),
      dirty: true)

proc addPaddle*(game: var Game): int =
   result = createEntity(game)

   mixTransform2d(game, result)
   template transform: untyped = game.transform[result]
   transform.translation[0] = game.windowWidth / 2
   transform.translation[1] = game.windowHeight - 20

   mixDraw2d(game, result)
   template draw: untyped = game.draw2d[result]
   draw.width = 100
   draw.height = 20
   draw.color[0] = 0xFF
   draw.color[1] = 0x00
   draw.color[2] = 0x00

   mixControlPaddle(game, result)

   mixMove(game, result)
   template move: untyped = game.move[result]
   move.speed = 500

   mixCollide(game, result)
   template collide: untyped = game.collide[result]
   collide.size[0] = 100
   collide.size[1] = 20

proc addBall*(game: var Game): int =
   result = createEntity(game)

   mixTransform2d(game, result)
   template transform: untyped = game.transform[result]
   transform.translation[0] = game.windowWidth / 2
   transform.translation[1] = game.windowHeight - 100

   mixDraw2d(game, result)
   template draw: untyped = game.draw2d[result]
   draw.width = 20
   draw.height = 20
   draw.color[0] = 0xFF
   draw.color[1] = 0xFF
   draw.color[2] = 0x00

   mixControlBall(game, result)
   template control: untyped = game.controllBall[result]
   let angle = -rand(1.0) * Pi
   control.direction[0] = cos(angle)
   control.direction[1] = sin(angle)

   mixMove(game, result)
   template move: untyped = game.move[result]
   move.speed = 300

   mixCollide(game, result)
   template collide: untyped = game.collide[result]
   collide.size[0] = 20
   collide.size[1] = 20

proc addExplosion*(game: var Game, x, y: float32): int =
   result = createEntity(game)
   let explosions = 32
   let step = (Pi * 2.0) / explosions
   let fadeStep = 0.05
   var children: seq[int]

   for i in 0 ..< explosions:
      let explosion = createEntity(game)

      mixTransform2d(game, explosion)
      template transform: untyped = game.transform[explosion]
      transform.parent = result

      mixDraw2d(game, explosion)
      template draw: untyped = game.draw2d[explosion]
      draw.width = 20
      draw.height = 20
      draw.color[0] = 0xFF
      draw.color[1] = 0xFF
      draw.color[2] = 0xFF

      mixMove(game, explosion)
      template move: untyped = game.move[explosion]
      move.direction[0] = sin(step * i)
      move.direction[1] = cos(step * i)
      move.speed = 800.0

      mixFade(game, explosion)
      template fade: untyped = game.fade[explosion]
      fade.step = fadeStep

      children.add explosion

   mixTransform2d(game, result)
   template transform: untyped = game.transform[result]
   transform.translation[0] = x
   transform.translation[1] = y
   transform.children = children

proc addBlock*(game: var Game, x, y: float32, width, height: int32): int =
   result = createEntity(game)

   mixTransform2d(game, result)
   template transform: untyped = game.transform[result]
   transform.translation[0] = x
   transform.translation[1] = y

   mixDraw2d(game, result)
   template draw: untyped = game.draw2d[result]
   draw.width = width
   draw.height = height
   draw.color[0] = 0x00
   draw.color[1] = 0xFF
   draw.color[2] = 0x55

   mixControlBrick(game, result)

   mixCollide(game, result)
   template collide: untyped = game.collide[result]
   collide.size[0] = width
   collide.size[1] = height

proc sceneMain*(game: var Game) =
   let camera = createEntity(game)
   game.camera = camera
   mixFade(game, camera)
   mixTransform2d(game, camera)
   template transform: untyped = game.transform[camera]

   transform.children.add game.addPaddle()
   transform.children.add game.addBall()

   let columnCount = 10
   let rowCount = 10
   let blockWidth = 50
   let blockHeight = 15
   let margin = 5

   let gridWidth = blockWidth * columnCount + margin * (columnCount - 1)
   let startingX = (game.windowWidth - gridWidth) / 2
   let startingY = 50

   for row in 0 ..< rowCount:
      let y = startingY + row * (blockHeight + margin) + blockHeight / 2
      for col in 0 ..< columnCount:
         let x = startingX + col * (blockWidth + margin) + blockWidth / 2
         let blockId = game.addBlock(x.float32, y.float32, blockWidth, blockHeight)
         transform.children.add blockId
