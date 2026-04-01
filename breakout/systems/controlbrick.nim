import ".."/[blueprints, gametypes, procgen]

proc updateBrick(game: var Game; brick: var Brick) =
  if not brick.dead and Hit in brick.collide.collision.flags:
    brick.fade.step = 0.05
    let position = game.nodes[brick.node.int].transform.translation
    let spawnSeed = eventSeed(2'u32, game.tickId, position.x, position.y)
    if chanceFromSeed(spawnSeed) > 0.98:
      game.createBall(
        float32(game.windowWidth / 2),
        float32(game.windowHeight / 2),
        spawnSeed
      )

proc sysControlBrick*(game: var Game) =
  for brick in game.bricks.mitems:
    game.updateBrick(brick)
