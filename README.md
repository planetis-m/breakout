# breakout-ecs

This is a port of [rs-breakout](https://github.com/michalbe/rs-breakout)
"A Breakout clone written in Rust using a strict ECS architecture" to Nim.
It was done for learning purposes. It also incorporates improvements done by me.
These are explained below.

## Blueprints dsl

``addBlueprint`` is a macro that allows you to declaratively specify an entity and its components.
This gets translated to ``mixin`` proc calls that register the components under the correct entity.
This macro supports nested entities (children) and composes perfectly with user-made procedures.

```nim
proc getExplosion*(self: var Game, parent = self.camera, x, y: float32): int =
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
```

For now ``Transform2d``, ``Hierarchy`` and ``Previous`` components are builtin for every entity.
This is how the original ``Blueprint`` works and might change in the future to this:

```nim
proc getBall*(self: var Game, parent = self.camera, x, y: float32): int =
   let angle = Pi + rand(1.0) * Pi
   result = self.addBlueprint:
      with:
         Transform2d(translation: Vec2(x: x, y: y))
         Hierarchy(parent: parent)
         Previous()
         Collide(size: Vec2(x: 20.0, y: 20.0))
         ControlBall(angle: angle)
         Draw2d(width: 20, height: 20, color: [0'u8, 255, 0, 255])
         Move(direction: Vec2(x: 1.0, y: 1.0), speed: 600.0)
```

## Run systems in parallel (Wip)

```nim
inParallel(self):
   sysHandleInput(writes = {HasInputState})
   sysControlBall:
      reads = {HasCollide}
      writes = {HasTransform2d, HasMove, HasControlBall, HasShake}
   sysControlBrick(reads = {HasCollide}, writes = {HasFade})
   sysControlPaddle(reads = {HasInputState}, writes = {HasMove})
```
