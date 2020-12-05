import ".." / [game_types, utils, registry, storage]

const Query = {HasTransform2d, HasFade, HasDraw2d}

proc update(game: var Game, entity: Entity, id: int64) =
   template transform: untyped = game.transform[entity.index]
   template fade: untyped = game.fade[entity.index]
   template draw: untyped = game.draw2d[entity.index]

   if draw.color[3] > 0:
      let step = 255.0 * fade.step
      draw.color[3] = draw.color[3] - step.uint8
      transform.scale.x -= fade.step
      transform.scale.y -= fade.step

      if entity.index == 192:
         echo "sysfade ", id, " ", isValid(entity, game.entities)
      game.dirty.add(entity)

      if transform.scale.x <= 0.0:
         game.delete(entity)

proc sysFade*(game: var Game, id: int64) =
   for entity, has in game.world.pairs:
      if has * Query == Query:
         update(game, entity, id)
