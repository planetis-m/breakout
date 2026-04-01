# breakout-ecs

A small Breakout clone in Nim that doubles as a compact ECS playground: fixed-timestep simulation, hierarchical transforms, explicit component storage, and a minimal raylib platform layer.

## Why Try It?

- Strict ECS without drowning in framework code.
- Fixed-step gameplay with interpolation, so the game loop stays easy to reason about.
- Dense component storage plus entity signatures instead of scanning `MAX_ENTITIES`.
- Small enough to read in one sitting, but still complete enough to be useful as a reference.
- Runs on Linux, macOS, and Windows through the same core game code.

## What It Looks Like

The scene is built from a few direct helpers:

```nim
discard createPaddle(game.world, camera, float32(game.windowWidth / 2),
    float32(game.windowHeight - 30))
discard createBall(game.world, camera, float32(game.windowWidth / 2),
    float32(game.windowHeight - 60))
discard createBrick(game.world, camera, x.float32, y.float32,
    brickWidth.int32, brickHeight.int32)
```

And each entity is just explicit component registration:

```nim
proc createBall*(world: var World, parent: Entity, x, y: float32): Entity =
  let angle = Pi.float32 + rand(1.0'f32) * Pi.float32
  let entity = createEntity(world)
  mixTransform2d(world, entity, mat2d(), Vec2(x: x, y: y), Rad(0), vec2(1, 1), parent)
  mixCollide(world, entity, Vec2(x: 20.0, y: 20.0))
  mixControlBall(world, entity)
  mixDraw2d(world, entity, 20, 20, [0'u8, 255, 0, 255])
  mixMove(world, entity, Vec2(x: cos(angle), y: sin(angle)), 14)
  result = entity
```

## Install

You need:

- Nim
- raylib headers plus a shared raylib library next to the built game executable

The Nim package file is intentionally minimal:

```nim
requires "nim >= 1.5.0"
```

## Quick Start

### Linux

Build raylib as a shared library, copy it into the project root, then build the game:

```bash
git clone --depth 1 https://github.com/raysan5/raylib.git /tmp/raylib
make -C /tmp/raylib/src \
  PLATFORM=PLATFORM_DESKTOP \
  GLFW_LINUX_ENABLE_WAYLAND=TRUE \
  GLFW_LINUX_ENABLE_X11=FALSE \
  RAYLIB_LIBTYPE=SHARED \
  CUSTOM_CFLAGS='-DSUPPORT_CUSTOM_FRAME_CONTROL=1'
cp /tmp/raylib/src/raylib.h .
cp /tmp/raylib/src/libraylib.so* .
nim c -d:release game.nim
./game
```

### Windows

Install `raylib` with vcpkg, copy `raylib.dll` next to the executable, then build with Nim's MSVC backend:

```powershell
nim c --cc:vcc -d:VcpkgRoot="C:\path\to\vcpkg\installed\x64-windows-release" -d:release game.nim
```

### macOS

Build raylib as a shared library and place `raylib.h` plus `libraylib*.dylib` in the project root before compiling:

```bash
nim c -d:release game.nim
./game
```

## What To Look At

If you are reading the code for ideas, start here:

- [game.nim](game.nim): fixed timestep loop, interpolation, and raylib frame control.
- [breakout/blueprints.nim](breakout/blueprints.nim): scene creation helpers for paddle, ball, bricks, and particle explosion.
- [breakout/mixins.nim](breakout/mixins.nim): the small API for attaching components to entities.
- [breakout/slottables.nim](breakout/slottables.nim): the slot-table based entity store.
- [breakout/systems](breakout/systems): the game logic, one system per file.

## Core Ideas

### Fixed Timestep, Explicit Rendering

The game updates on a fixed simulation tick and renders with interpolation. Rendering and input polling are driven explicitly through raylib custom frame control, while gameplay timing stays on `MonoTime`.

### ECS Without Full-Framework Weight

Entities are lightweight IDs. Component presence is tracked by a signature set, and systems iterate only the entities that match their required components.

### Hierarchical Scene Graph

Transforms support parent-child relationships, so the camera and spawned effects can move as a group without introducing separate scene abstractions.

## Run Commands

Build a debug binary:

```bash
nim c game.nim
```

Build a release binary:

```bash
nim c -d:release game.nim
```

## Acknowledgments

- [rs-breakout](https://github.com/michalbe/rs-breakout)
- [Backcountry Architecture](https://piesku.com/backcountry/architecture)
- [ECS Back and Forth](https://skypjack.github.io/2019-02-14-ecs-baf-part-1/)
- [bitquid](http://bitsquid.blogspot.com/2014/10/building-data-oriented-entity-system.html)

## License

Distributed under the [MIT license](LICENSE).
