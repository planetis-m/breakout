# breakout-ecs

This is a port of [rs-breakout](https://github.com/michalbe/rs-breakout)
"A Breakout clone written in Rust using a strict ECS architecture" to Nim.
It was done for learning purposes. It also incorporates improvements done by me.
These are explained below.

## Entity management was redesigned

The original codebase when updating a system or creating a new entity, it iterates up
to ``MAX_ENTITIES``. This was eliminated by using a special data structure.

For entity management (creation, deletion) a ``slotmap`` data structure is used. It also holds
a dense sequence of ``set[HasComponent]`` which is the "signature" for each entity.
A signature is a bit-set describing the component composition of an entity.
This is used for iterating over all entities, skipping the ones that don't match a system's registered components.
These are encoded as `Query`, another bit-set and the check performed is: `signature * Query == Query`.

## Fixed timestep with interpolation

Alpha value is used to interpolate between next and previous transforms. Interpolation function
for `angles` was implemented.

## Improvements to the hierarchical scene graph

As explained by the original authors in their documentation for
[backcountry](https://piesku.com/backcountry/architecture#scene)

> Transforms can have child transforms attached to them. We use this to group
> entities into larger wholes (e.g. a character is a hierarchy of body parts,
> the hat and the gun).

I changed the implementation of ``children: [Option<usize>; MAX_CHILDREN]``
with the design described at
[skypjack's blog](https://skypjack.github.io/2019-06-25-ecs-baf-part-4/).
Now it is a seperate ``Hierarchy`` component following the unconstrained model.
Immediate updates are implemented by traversing this hierarchy using dfs traversal.

## Custom vector math library

A type safe vector math library was created for use in the game. ``distinct`` types are
used to prohibit operations that have no physical meaning, such as adding two points.

```nim
type
  Rad* = distinct float32

func lerp*(a, b: Rad, t: float32): Rad =
  # interpolates angles

type
  Vec2* = object
    x*, y*: float32

  Point2* {.borrow: `.`.} = distinct Vec2

func `+`*(a, b: Vec2): Vec2
func `-`*(a, b: Point2): Vec2
func `+`*(p: Point2, v: Vec2): Point2
func `-`*(p: Point2, v: Vec2): Point2
func `+`*(a, b: Point2): Point2 {.
    error: "Adding 2 Point2s doesn't make physical sense".}
```

## Blueprints DSL

``addBlueprint`` is a macro that allows you to declaratively specify an entity and its components.
It produces ``mixin`` proc calls that register the components for the entity with the arguments specified.
The macro also supports nested entities (children in the hierarchical scene graph) and composes perfectly
with user-made procedures. These must have signature ``proc (w: World, e: Entity, ...): Entity``
and tagged with ``entity``.

### Examples

1. Creates a new entity, with these components, returns the entity handle.

```nim
let ent1 = game.addBlueprint(with Transform2d(), Fade(step: 0.5), Collide(size: vec2(100.0, 20.0)), Move(speed: 600.0))
```

2. Specifies a hierarchy of entities, the children (explosion particles) are built inside a loop.
The `addBlueprint` macro composes with all of Nim's control flow constructs.

```nim
proc getExplosion*(world: var World, parent: Entity, x, y: float32): Entity =
  let explosions = 32
  let step = (Pi * 2.0) / explosions.float
  let fadeStep = 0.05
  result = world.addBlueprint(explosion):
    with:
      Transform2d(translation: Vec2(x: x, y: y), parent: parent)
    children:
      for i in 0 ..< explosions:
        blueprint:
          with:
            Transform2d(parent: explosion)
            Draw2d(width: 20, height: 20, color: [255'u8, 255, 255, 255])
            Fade(step: fadeStep)
            Move(direction: Vec2(x: sin(step * i.float), y: cos(step * i.float)), speed: 20.0)
```

It expands to:

```
let explosion = createEntity(world)
mixTransform2d(world, explosion, mat2d(), Vec2(x: x, y: y), Rad(0), vec2(1, 1),
               parent)
for i in 0 ..< explosions:
  let :tmp_1493172298 = createEntity(world)
  mixTransform2d(world, :tmp_1493172298, mat2d(), vec2(0, 0), Rad(0),
                 vec2(1, 1), explosion)
  mixDraw2d(world, :tmp_1493172298, 20, 20, [255'u8, 255, 255, 255])
  mixFade(world, :tmp_1493172298, fadeStep)
  mixMove(world, :tmp_1493172298,
          Vec2(x: sin(step * float(i)), y: cos(step * float(i))), 20.0)
explosion
```

## Acknowledgments

- [Fixed-Time-Step Implementation](http://lspiroengine.com/?p=378)
- [bitquid](http://bitsquid.blogspot.com/2014/10/building-data-oriented-entity-system.html)
- [Goodluck](https://github.com/piesku/goodluck) A hackable template for creating small and fast browser games.
- [rs-breakout](https://github.com/michalbe/rs-breakout)
- [Breakout Tutorial](https://github.com/piesku/breakout/tree/tutorial)
- [Backcountry Architecture](https://piesku.com/backcountry/architecture) lessons learned when using ECS in a game
- [ECS Back and Forth](https://skypjack.github.io/2019-02-14-ecs-baf-part-1/) excellent series that describe ECS designs
- [ECS with sparse array notes](https://gist.github.com/dakom/82551fff5d2b843cbe1601bbaff2acbf)
- [Trace of Radiance](https://github.com/mratsim/trace-of-radiance#correctness) the idea of using distinct types in a math lib
- #nim-gamedev, a friendly community interested in making games with nim.

## License
This library is distributed under the [MIT license](LICENSE).
