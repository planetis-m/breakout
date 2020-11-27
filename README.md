# breakout-ecs

This is a port of [rs-breakout](https://github.com/michalbe/rs-breakout)
"A Breakout clone written in Rust using a strict ECS architecture" to Nim.
It was done for learning purposes. It also incorporates improvements done by me.
These are explained below.

## Entity management was redesigned

The original codebase when updating a system or creating a new entity, it iterates up
to ``MAX_ENTITIES``. This was eliminated by using two special data structures.

For entity management (creation, deletion) a ``slotmap`` data structure is used, as explained
in [ECS back and forth part 3](https://skypjack.github.io/2019-05-06-ecs-baf-part-3/).

For iterating over all entities, a sparse set that contains a ``set[HasComponent]`` is used.
There are still improvements to be made in this aspect.

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

### Sorting for hierachies

Implemented using selection sort over `dirty: seq[Entities]`. Followed the idea in
[bitquid](http://bitsquid.blogspot.com/2014/10/building-data-oriented-entity-system.html)
blog. Might worth switching to immediate updates in the future.

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
It produces ``mixin`` proc calls that register the components for the entity (with the arguments specified).
The macro also supports nested entities (children in the hierarchical scene graph) and composes perfectly
with user-made procedures (these must have a specific signature and tagged with ``entity``).

### Examples

1) Creates a new entity, with these components, returns the entity handle.

```nim
let ent1 = game.addBlueprint(with Fade(step: 0.5), Collide(size: vec2(100.0, 20.0)), Move(speed: 600.0))
```

Note: ``Transform2d`` and ``Hierarchy`` components are always implied.

2) Specifies a hierarchy of entities, the children (explosion particles) are built inside a loop
(it composes with all of Nim's control flow constructs).

```nim
proc getExplosion*(game: var Game, parent = game.camera, x, y: float32): Entity =
   let explosions = 32
   let step = (Pi * 2.0) / explosions.float
   let fadeStep = 0.05
   result = game.addBlueprint:
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

It expands to:

```
let blueprintResult_13135030 = createEntity(game)
mixTransform2d(game, blueprintResult_13135030, Vec2(x: x, y: y), 0.0, vec2(1, 1))
mixHierarchy(game, blueprintResult_13135030, parent)
mixDirty(game, blueprintResult_13135030)
for i in 0 ..< explosions:
   let :tmp_13135040 = createEntity(game)
   mixTransform2d(game, :tmp_13135040, vec2(0, 0), 0.0, vec2(1, 1))
   mixHierarchy(game, :tmp_13135040, blueprintResult_13135030)
   mixDirty(game, :tmp_13135040)
   mixDraw2d(game, :tmp_13135040, 20, 20, [255'u8, 255, 255, 255])
   mixFade(game, :tmp_13135040, fadeStep)
   mixMove(game, :tmp_13135040,
         Vec2(x: sin(step * float(i)), y: cos(step * float(i))), 800.0)
blueprintResult_13135030
```

## Acknowledgments

- [Fixed-Time-Step Implementation](http://lspiroengine.com/?p=378)
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
