import std/random
import ".."/[blueprints, gametypes]

proc updateBrick(game: var Game; brick: var Brick) =
  if not brick.dead and Hit in brick.collide.collision.flags:
    brick.fade.step = 0.05
    if rand(1.0) > 0.98:
      game.createBall(
        float32(game.windowWidth / 2),
        float32(game.windowHeight / 2)
      )

proc sysControlBrick*(game: var Game) =
  for brick in game.bricks.mitems:
    game.updateBrick(brick)
