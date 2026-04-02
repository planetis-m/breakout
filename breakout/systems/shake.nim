import std/random
import ".."/gamecore

proc updateCameraShake(game: var Game) =
  let node = game.camera.node
  template transform: untyped = game.nodes[node.int].transform

  if game.camera.shake.duration > 0:
    game.camera.shake.duration -= 0.01
    transform.translation.x = game.camera.shake.strength -
      rand(game.camera.shake.strength * 2)
    transform.translation.y = game.camera.shake.strength -
      rand(game.camera.shake.strength * 2)

    game.clearColor.r = rand(255).uint8
    game.clearColor.g = rand(255).uint8
    game.clearColor.b = rand(255).uint8
    game.markDirty(node)

    if game.camera.shake.duration <= 0:
      game.camera.shake.duration = 0
      transform.translation.x = 0
      transform.translation.y = 0
      game.clearColor.r = 0
      game.clearColor.g = 0
      game.clearColor.b = 0
      game.markDirty(node)

proc sysShake*(game: var Game) =
  game.updateCameraShake()
