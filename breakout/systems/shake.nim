import std/random
import ".."/gametypes

proc updateCameraShake(game: var Game) =
  let node = game.camera.node
  template transform: untyped = game.nodes[node.int].transform

  if game.camera.shake.duration > 0:
    game.camera.shake.duration -= 0.01
    transform.translation.x = game.camera.shake.strength -
      rand(game.camera.shake.strength * 2)
    transform.translation.y = game.camera.shake.strength -
      rand(game.camera.shake.strength * 2)

    game.clearColor[0] = rand(255).uint8
    game.clearColor[1] = rand(255).uint8
    game.clearColor[2] = rand(255).uint8
    game.markDirty(node)

    if game.camera.shake.duration <= 0:
      game.camera.shake.duration = 0
      transform.translation.x = 0
      transform.translation.y = 0
      game.clearColor[0] = 0
      game.clearColor[1] = 0
      game.clearColor[2] = 0
      game.markDirty(node)

proc sysShake*(game: var Game) =
  game.updateCameraShake()
