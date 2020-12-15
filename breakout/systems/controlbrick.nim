import ".." / [gametypes, heaparray, blueprints, slotmap], std / random

const Query = {HasControlBrick, HasCollide, HasFade}

proc update(game: var Game, entity: Entity) =
  template collide: untyped = game.world.collide[entity.idx]
  template fade: untyped = game.world.fade[entity.idx]

  if collide.collision.other != invalidId:
    fade.step = 0.05

    if rand(1.0) > 0.98:
      discard game.world.getBall(game.camera, float32(game.windowWidth / 2),
            float32(game.windowHeight / 2))

proc sysControlBrick*(game: var Game) =
  for entity, has in game.world.signature.pairs:
    if has * Query == Query:
      update(game, entity)
