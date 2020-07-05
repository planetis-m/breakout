import ".." / [game_types, vmath, mixins, registry, storage]

const Query = {HasTransform2d}

proc update(game: var Game, entity: Entity, intrpl: float32) =
   template transform: untyped = game.transform[entity.index]

   let position = transform.world.origin
   let rotation = transform.world.rotation
   let scale = transform.world.scale

   if HasPrevious in game.world[entity]:
      template previous: untyped = game.previous[entity.index]

      game.mixCurrent(entity,
            lerp(previous.position, position, intrpl),
            lerp(previous.rotation, rotation, intrpl),
            lerp(previous.scale, scale, intrpl))

   game.mixPrevious(entity, position, rotation, scale)

proc sysIntrpl2d*(game: var Game, intrpl: float32) =
   for (entity, has) in game.world.pairs:
      if has * Query == Query:
         update(game, entity, intrpl)
