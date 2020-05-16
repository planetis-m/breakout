import macros, math, vmath, game_types

proc mixCollide(self: var Game, entity: int, size = vec2(0, 0)) =
   self.world[entity].incl HasCollide
   self.collide[entity] = Collide(entity: entity, size: size)

proc mixControlBall(self: var Game, entity: int, angle = Pi * 0.33) =
   self.world[entity].incl HasControlBall
   self.controlBall[entity] = ControlBall(direction: vec2(cos(angle), sin(angle)))

proc mixControlBrick(self: var Game, entity: int) =
   self.world[entity].incl HasControlBrick

proc mixControlPaddle(self: var Game, entity: int) =
   self.world[entity].incl HasControlPaddle

proc mixDraw2d(self: var Game, entity: int, width, height = 100,
      color = [255'u8, 0, 255, 255]) =
   self.world[entity].incl HasDraw2d
   self.draw2d[entity] = Draw2d(width: width, height: height, color: color)

proc mixFade(self: var Game, entity: int, step = 0.0) =
   self.world[entity].incl HasFade
   self.fade[entity] = Fade(step: step)

proc mixHierarchy(self: var Game, entity: int, parent = self.camera) =
   self.world[entity].incl HasHierarchy
   if parent > -1: prependNode(self, parent, entity)

proc mixMove(self: var Game, entity: int, direction = vec2(0, 0), speed = 100) =
   self.world[entity].incl HasMove
   self.move[entity] = Move(direction: direction, speed: speed)

proc mixPrevious(self: var Game, entity: int) =
   self.world[entity].incl HasPrevious
   #self.previous[entity] = Previous(world: mat2d())

proc mixShake(self: var Game, entity: int, duration = 1.0, strength = 0.0) =
   self.world[entity].incl HasShake
   self.shake[entity] = Shake(duration: duration, strength: strength)

proc mixTransform2d(self: var Game, entity: int, translation = vec2(0, 0),
      rotation = 0.0, scale = vec2(1, 1)) =
   self.world[entity].incl HasTransform2d
   self.transform2d[entity] = Transform2D(world: mat2d(), self: mat2d(),
         translation: translation, rotation: rotation, scale: scale, dirty: true)

proc getBall*(self: var Game, parent = self.camera): int =
   let angle = Pi + rand(1.0) * Pi
   result = self.addBlueprint:
      translation = Vec(x: x, y: y)
      parent = parent
      with:
         Collide(size: Vec2(x: 20.0, y: 20.0))
         ControlBall(angle: angle)
         Draw2d(width: 20, height: 20, color: [0'u8, 255, 0, 255])
         Move(direction: Vec2(x: 1.0, y: 1.0), speed: 600.0)

proc getBrick*(self: var Game, parent = self.camera, x, y: float32, width, height: int32): int =
   result = self.addBlueprint:
      translation = Vec(x: x, y: y)
      parent = parent
      with:
         Collide(size: Vec2(x: width, y: height))
         ControlBlock()
         Draw2d(width: 20, height: 20, color: [255'u8, 255, 0, 255])
         Fade(step: 0.0)

proc getExplosion(self: var Game, parent = self.camera, x, y: float32): int =
   let explosions = 32
   let step = (Pi * 2.0) / explosions
   let fadeStep = 0.05
   result = self.addBlueprint:
      translation = Vec(x: x, y: y)
      parent = parent
      children:
         for i in 0 ..< explosions:
            blueprint:
               with:
                  Draw2d(width: 20, height: 20, color: [255'u8, 255, 255, 255])
                  Fade(step: fadeStep)
                  Move(direction: Vec2(x: sin(step * i), y: cos(step * i)), speed: 800.0)

proc getPaddle(self: var Game, parent = self.camera, x, y: float32): int =
   result = self.addBlueprint:
      translation = Vec(x: x, y: y)
      parent = parent
      with:
         Collide(size: Vec2(x: 100.0, y: 20.0))
         ControlPaddle()
         Draw2d(width: 100, height: 20, color: [255'u8, 0, 0, 255])
         Move(speed: 600.0)

proc sceneMain*(self: var Game) =
   let columnCount = 10
   let rowCount = 10
   let brickWidth = 50
   let brickHeight = 15
   let margin = 5

   let gridWidth = brickWidth * columnCount + margin * (columnCount - 1)
   let startingX = (self.windowWidth - gridWidth) / 2
   let startingY = 50

   self.camera = self.addBlueprint:
      with(Shake(duration: 0.0, strength: 20.0))
      children:
         entity(getPaddle(float32(self.windowWidth / 2),
               float32(self.windowHeight - 30)))
         entity(getBall(float32(self.windowWidth / 2),
               float32(self.windowHeight - 60)))

         for row in 0 ..< rowCount:
            let y = startingY + row * (brickHeight + margin) + brickHeight / 2
            for col in 0 ..< columnCount:
               let x = startingX + col * (brickWidth + margin) + brickWidth / 2
               entity(getBrick(x.float32, y.float32, brickWidth, brickHeight))
