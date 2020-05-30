# breakout-ecs

This is a port of [rs-breakout](https://github.com/michalbe/rs-breakout)
"A Breakout clone written in Rust using a strict ECS architecture" to Nim.
It was done for learning purposes. It also incorporates improvements done by me.
These are explained below.

## Improvements to the hierarchical scene graph

As explained by the original authors in their documentation for
[backcountry](https://piesku.com/backcountry/architecture#scene)

> Transforms can have child transforms attached to them. We use this to group
> entities into larger wholes (e.g. a character is a hierarchy of body parts,
> the hat and the gun).

However I found the implementation, space inefficient since its declared as
``children: [Option<usize>; MAX_CHILDREN]``, where ``MAX_CHILDREN`` is ``1000``.
To fix it I used the design described at
[skypjack's blog](https://skypjack.github.io/2019-06-25-ecs-baf-part-4/).
Now it is a seperate ``Hierarchy`` component following the unconstrained model.

## Blueprints DSL

``addBlueprint`` is a macro that allows you to declaratively specify an entity and its components.
This gets translated to ``mixin`` proc calls that register the components under the correct entity.
This macro supports nested entities (children in the hierarchical scene graph) and composes perfectly
with user-made procedures.

### Examples

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

For ``Transform2d``, ``Hierarchy`` and ``Previous`` components are builtin for every entity.

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

## Acknowledgments

- [rs-breakout](https://github.com/michalbe/rs-breakout) the original game
- [Breakout Tutorial](https://github.com/piesku/breakout/tree/tutorial) my introduction to games
- [Fireblade](https://github.com/fireblade-engine/ecs) as an inspiration
- [ECS Back and Forth](https://skypjack.github.io/2019-02-14-ecs-baf-part-1/) excellent explanation of ECS
- [zig-sparse-set](https://github.com/Srekel/zig-sparse-set) helped understanding sparse sets, although not used
- People on #nim-gamedev for answering my questions
