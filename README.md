# breakout

A small Breakout clone in Nim built as a clear data-oriented game code example:
typed game state, direct arrays of objects, explicit systems, hierarchical
transforms, and a fixed-timestep loop on top of raylib.

## Who This Is For

This project is mainly for:

- Nim programmers who want a complete but readable game sample.
- People studying data-oriented design without wanting a full engine or ECS framework.
- Developers who like game code that stays explicit: update order, storage, and side effects are all easy to trace.

If you want a polished engine, editor tooling, scripting, or a reusable gameplay
framework, this is not that project. This is a compact codebase you can read in
an afternoon and learn from.

## Why It Is Worth Reading

- The game state is concrete and direct. `Game` owns parallel component arrays
  for balls, bricks, particles, trails, and transform nodes instead of routing
  everything through a generic entity abstraction.
- Systems stay small and obvious. Movement, collision, fade, shake, transform,
  and draw each live in their own file.
- The transform graph is still hierarchical, so the camera and spawned effects
  can move as a group without a heavier scene abstraction.
- The main loop uses a fixed simulation step with interpolation, which keeps
  gameplay deterministic per tick while rendering stays smooth.
- The whole project is small enough to fork, rewrite, and experiment with.

## What The Code Looks Like

Scene setup is plain data construction:

```nim
game.camera = Camera(
  node: game.allocNode(vec2(0, 0)),
  shake: Shake(duration: 0, strength: 10)
)

game.createPaddle(
  float32(game.windowWidth / 2),
  float32(game.windowHeight - 30)
)
game.createBall(
  float32(game.windowWidth / 2),
  float32(game.windowHeight - 60)
)
```

And systems work directly on typed indexed storage:

```nim
proc moveNode(game: var Game; node: NodeIdx; move: Move) =
  if move.direction.x != 0 or move.direction.y != 0:
    template transform: untyped = game.nodes[node.int].transform
    transform.translation.x += move.direction.x * move.speed
    transform.translation.y += move.direction.y * move.speed
    game.markDirty(node)
```

That is the main point of the project: simple data, simple passes, and no
framework magic.

## Quick Start

### Linux

The repository is set up to compile against `raylib.h` and `libraylib.so`
located in the project root.

If you already have those files in place:

```bash
nim c -d:release game.nim
./game
```

If you need to build raylib first:

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

### macOS

Build raylib as a shared library, then place `raylib.h` and the resulting
`libraylib*.dylib` in the project root:

```bash
nim c -d:release game.nim
./game
```

### Windows

Windows builds expect a vcpkg raylib install and require `VcpkgRoot`:

```powershell
nim c --cc:vcc -d:VcpkgRoot="C:\path\to\vcpkg\installed\x64-windows-release" -d:release game.nim
```

## Controls

- `Left Arrow` or `A`: move paddle left
- `Right Arrow` or `D`: move paddle right
- `Esc`: quit

## Project Map

Start here if you are reading the code:

- [game.nim](game.nim): window setup, fixed-step loop, interpolation, and render cadence.
- [breakout/gametypes.nim](breakout/gametypes.nim): the core data model, including `Game`, `TransformNode`, and the typed gameplay objects.
- [breakout/blueprints.nim](breakout/blueprints.nim): scene construction plus spawning helpers for balls, bricks, trails, and particles.
- [breakout/systems/transform2d.nim](breakout/systems/transform2d.nim): hierarchical transform propagation and previous-frame data for interpolation.
- [breakout/systems/collide.nim](breakout/systems/collide.nim): AABB preparation and collision resolution flags.
- [breakout/systems/draw2d.nim](breakout/systems/draw2d.nim): interpolated rectangle rendering through raylib.

## Core Ideas

### Direct Data Over Generic Abstractions

The code keeps concrete gameplay data front and center. You can search for ball,
brick, or paddle storage and immediately find the matching update logic and
rendering path.

### Fixed Timestep With Interpolated Rendering

Simulation runs on a fixed tick. Rendering interpolates between the previous and
current world transform, which is enough to keep movement readable without
complicating the game loop.

### Small Systems, Explicit Order

`game.update()` calls the systems in a deliberate order:

1. control
2. shake and fade
3. cleanup
4. movement
5. transform propagation
6. collision

That order is easy to inspect and easy to change.

## Build Commands

Debug build:

```bash
nim c game.nim
```

Release build:

```bash
nim c -d:release game.nim
```

## Acknowledgments

- [rs-breakout](https://github.com/michalbe/rs-breakout)
- [Backcountry Architecture](https://piesku.com/backcountry/architecture)
- [bitquid](http://bitsquid.blogspot.com/2014/10/building-data-oriented-entity-system.html)

## License

Distributed under the [MIT license](LICENSE).
