import std/random
import ".."/gametypes

proc sysShake*(game: var Game) =
  let transformIdx = game.camera.transform
  var transform = addr game.transforms[transformIdx.int]
  var shake = addr game.camera.shake

  if shake.duration > 0:
    shake.duration -= 0.01
    transform.translation.x = shake.strength - rand(shake.strength * 2)
    transform.translation.y = shake.strength - rand(shake.strength * 2)

    game.clearColor[0] = rand(255).uint8
    game.clearColor[1] = rand(255).uint8
    game.clearColor[2] = rand(255).uint8
    transform.dirty = true

    if shake.duration <= 0:
      shake.duration = 0
      transform.translation.x = 0
      transform.translation.y = 0
      game.clearColor[0] = 0
      game.clearColor[1] = 0
      game.clearColor[2] = 0
