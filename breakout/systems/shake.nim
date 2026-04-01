import std/random
import ".."/gamecore

proc updateCameraShake(game: var Game) =
  let node = game.camera.node
  template shake: untyped = game.shakes[game.camera.shake.int]
  template transform: untyped = game.transforms[node.int]

  if shake.duration > 0:
    shake.duration -= 0.01
    transform.translation.x = shake.strength - rand(shake.strength * 2)
    transform.translation.y = shake.strength - rand(shake.strength * 2)

    game.clearColor[0] = rand(255).uint8
    game.clearColor[1] = rand(255).uint8
    game.clearColor[2] = rand(255).uint8
    game.markDirty(node)

    if shake.duration <= 0:
      shake.duration = 0
      transform.translation.x = 0
      transform.translation.y = 0
      game.clearColor[0] = 0
      game.clearColor[1] = 0
      game.clearColor[2] = 0
      game.markDirty(node)

proc sysShake*(game: var Game) =
  game.updateCameraShake()
