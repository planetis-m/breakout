type
   Blueprint = object
      translation: Vec2
      rotation: float32
      scale: Vec2
      with: seq[proc(game: var Game, entity: int)],
      children: seq[Blueprint]

proc getBall(x, y: float32): Blueprint =
   let angle = Pi + rand(1.0) * Pi
   Blueprint(
      translation: Vec(x: x, y: y),
      with: @[
         Draw2d(width: 20, height: 20, color: [0'u8, 255, 0, 255]),
         Move(direction: Vec2(x: 1.0, y: 1.0), speed: 600.0)),
         ControlBall(direction: angle),
         Collide(size: Vec2(x: 20.0, y: 20.0))])

proc getBlock(x, y: float32, width, height: int): Blueprint =
   Blueprint(
      translation: Vec(x: x, y: y),
      with: @[
         Draw2d(width: 20, height: 20, color: [255'u8, 255, 0, 255]),
         Collide(size: Vec2(x: width, y: height)),
         ControlBlock(),
         Fade(step: 0.0)])

proc getExplosion(x, y: float32): Blueprint =
   let explosions = 32
   var children: seq[Blueprint]
   let step = (Pi * 2.0) / explosions
   let fadeStep = 0.05

   for i in 0 ..< explosions:
      children.add(Blueprint(
         with: @[
            Draw2d(width: 20, height: 20, color: [255'u8, 255, 255, 255]),
            Move(direction: Vec2(x: sin(step * i), y: cos(step * i)), speed: 800.0),
            Fade(step: fadeStep))),

    Blueprint(
        translation: Vec(x: x, y: y),
        children: children)

proc getPaddle(x, y: float32): Blueprint =
   Blueprint(
      translation: Vec(x: x, y: y),
      with: @[
         Draw2d(width: 100, height: 20, color: [255'u8, 0, 0, 255]),
         Collide(size: Vec2(x: 100.0, y: 20.0)),
         Move(speed: 600.0),
         ControlPaddle()])
