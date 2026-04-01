import ".."/[gametypes, procgen]

proc updateCameraShake(game: var Game) =
  let node = game.camera.node

  if game.camera.shake.duration > 0:
    game.camera.shake.duration -= 0.01
    game.nodes[node.int].transform.translation.x =
      shakeOffsetFromTick(game.tickId, 0, game.camera.shake.strength)
    game.nodes[node.int].transform.translation.y =
      shakeOffsetFromTick(game.tickId, 1, game.camera.shake.strength)

    game.clearColor[0] = shakeColorFromTick(game.tickId, 0)
    game.clearColor[1] = shakeColorFromTick(game.tickId, 1)
    game.clearColor[2] = shakeColorFromTick(game.tickId, 2)
    game.markDirty(node)

    if game.camera.shake.duration <= 0:
      game.camera.shake.duration = 0
      game.nodes[node.int].transform.translation.x = 0
      game.nodes[node.int].transform.translation.y = 0
      game.clearColor[0] = 0
      game.clearColor[1] = 0
      game.clearColor[2] = 0
      game.markDirty(node)

proc sysShake*(game: var Game) =
  game.updateCameraShake()
