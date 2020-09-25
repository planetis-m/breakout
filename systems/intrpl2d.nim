import ".." / [game_types, vmath, mixins, registry, storage, utils]

const Query = {HasTransform2d, HasPrevious}

proc update(game: var Game, entity: Entity, intrpl: float32) =
   template transform: untyped = game.transform[entity.index]
   template previous: untyped = game.previous[entity.index]

   let position = lerp(previous.position, transform.world.origin, intrpl)
   let rotation = lerp(previous.rotation, transform.world.rotation, intrpl)
   let scale = lerp(previous.scale, transform.world.scale, intrpl)

   game.mixCurrent(entity, position, rotation, scale)

proc sysIntrpl2d*(game: var Game, intrpl: float32) =
   for (entity, has) in game.world.pairs:
      if has * Query == Query:
         update(game, entity, intrpl)
