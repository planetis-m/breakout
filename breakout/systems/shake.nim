import ".."/[gametypes, heaparrays, vmath, builddsl, slottables], fusion/smartptrs, std/random

const Query = {HasTransform2d, HasShake}

proc update(game: var Game, entity: Entity) =
  template transform: untyped = game.world.transform[entity.idx]
  template shake: untyped = game.world.shake[]

  if shake.duration > 0:
    shake.duration -= 0.01
    transform.translation.x = shake.strength - rand(shake.strength * 2)
    transform.translation.y = shake.strength - rand(shake.strength * 2)

    game.clearColor[0] = rand(255).uint8
    game.clearColor[1] = rand(255).uint8
    game.clearColor[2] = rand(255).uint8

    game.world.mixDirty(entity)

    if shake.duration <= 0:
      shake.duration = 0
      transform.translation.x = 0
      transform.translation.y = 0
      game.clearColor[0] = 0
      game.clearColor[1] = 0
      game.clearColor[2] = 0

proc sysShake*(game: var Game) =
  let signature = game.world.signature[game.camera]
  if Query <= signature:
    update(game, game.camera)
