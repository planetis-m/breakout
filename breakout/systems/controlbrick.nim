import std/random
import ".."/[blueprints, gametypes]

proc sysControlBrick*(game: var Game) =
  for brick in mitems(game.bricks):
    if Alive in brick.flags and Hit in game.colliders[brick.collide.int].collision.flags:
      game.fades[brick.fade.int].step = 0.05
      if rand(1.0) > 0.98:
        game.createBall(
          float32(game.windowWidth / 2),
          float32(game.windowHeight / 2)
        )
