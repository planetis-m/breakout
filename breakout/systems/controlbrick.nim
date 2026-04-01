import std/random
import ".."/[blueprints, gametypes]

proc sysControlBrick*(game: var Game) =
  let actorCount = game.actors.len
  for i in 0..<actorCount:
    template brick: untyped = game.actors[i]
    if brick.kind == BrickKind and
        Hit in game.colliders[brick.collide].collision.flags:
      game.fades[brick.fade].step = 0.05
      if rand(1.0) > 0.98:
        game.createBall(
          float32(game.windowWidth / 2),
          float32(game.windowHeight / 2)
        )
