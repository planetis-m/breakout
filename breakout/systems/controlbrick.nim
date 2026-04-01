import std/random
import ".."/[blueprints, gamecore]

proc updateBrick(game: var Game; brick: var Brick) =
  if brick.fade.step == 0 and brick.collide.collision.hasHit:
    brick.fade.step = 0.05
    if rand(1.0) > 0.98:
      game.createBall(
        float32(game.windowWidth / 2),
        float32(game.windowHeight / 2)
      )

proc sysControlBrick*(game: var Game) =
  for brick in game.bricks.mitems:
    game.updateBrick(brick)
