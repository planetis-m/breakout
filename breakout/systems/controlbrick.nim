import std/random
import ".."/[blueprints, gamecore]

proc updateBrick(game: var Game; idx: BrickIdx) =
  template brick: untyped = game.bricks[idx.int]
  template fade: untyped = game.fades[brick.fade.int]
  if fade.step == 0 and game.collides[brick.collide.int].collision.hasHit:
    fade.step = 0.05
    if rand(1.0) > 0.98:
      game.createBall(
        float32(game.windowWidth / 2),
        float32(game.windowHeight / 2)
      )

proc sysControlBrick*(game: var Game) =
  for i in 0..<game.brickCount:
    game.updateBrick(BrickIdx(i.int32))
