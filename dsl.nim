import dsl_macro, random, math, vmath, game_types

proc getBall*(self: var Game, parent = self.camera, x, y: float32): int =
   let angle = Pi + rand(1.0) * Pi
   result = self.addBlueprint:
      translation = Vec2(x: x, y: y)
      parent = parent
      with:
         Collide(size: Vec2(x: 20.0, y: 20.0))
         ControlBall(angle: angle)
         Draw2d(width: 20, height: 20, color: [0'u8, 255, 0, 255])
         Move(direction: Vec2(x: 1.0, y: 1.0), speed: 600.0)

proc getBrick*(self: var Game, parent = self.camera, x, y: float32, width, height: int32): int =
   result = self.addBlueprint:
      translation = Vec2(x: x, y: y)
      parent = parent
      with:
         Collide(size: Vec2(x: width.float32, y: height.float32))
         ControlBrick()
         Draw2d(width: 20, height: 20, color: [255'u8, 255, 0, 255])
         Fade(step: 0.0)

proc getExplosion(self: var Game, parent = self.camera, x, y: float32): int =
   let explosions = 32
   let step = (Pi * 2.0) / explosions.float
   let fadeStep = 0.05
   result = self.addBlueprint:
      translation = Vec2(x: x, y: y)
      parent = parent
      children:
         for i in 0 ..< explosions:
            blueprint:
               with:
                  Draw2d(width: 20, height: 20, color: [255'u8, 255, 255, 255])
                  Fade(step: fadeStep)
                  Move(direction: Vec2(x: sin(step * i.float), y: cos(step * i.float)), speed: 800.0)

proc getPaddle(self: var Game, parent = self.camera, x, y: float32): int =
   result = self.addBlueprint:
      translation = Vec2(x: x, y: y)
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
   let startingX = (self.windowWidth - gridWidth) div 2
   let startingY = 50

   self.camera = self.addBlueprint:
      with(Shake(duration: 0.0, strength: 20.0))
      children:
         entity(getPaddle(float32(self.windowWidth / 2),
               float32(self.windowHeight - 30)))
         entity(getBall(float32(self.windowWidth / 2),
               float32(self.windowHeight - 60)))

         for row in 0 ..< rowCount:
            let y = startingY + row * (brickHeight + margin) + brickHeight div 2
            for col in 0 ..< columnCount:
               let x = startingX + col * (brickWidth + margin) + brickWidth div 2
               entity(getBrick(x.float32, y.float32, brickWidth.int32, brickHeight.int32))
