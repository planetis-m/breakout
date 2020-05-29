import game_types, utils

const Query = {HasTransform2d, HasFade, HasDraw2d}

proc update(game: var Game, entity: Entity) =
   template transform: untyped = game.transform[entity]
   template fade: untyped = game.fade[entity]
   template draw: untyped = game.draw2d[entity]

   if draw.color[3] > 0:
      let step = 255.0 * fade.step
      draw.color[3] = draw.color[3] - step.uint8
      transform.scale.x -= fade.step
      transform.scale.y -= fade.step
      transform.dirty = true

      if transform.scale.x <= 0.0:
         game.delete(entity)

proc sysFade*(game: var Game) =
   for i in 0 ..< MaxEntities:
      if game.world[i] * Query == Query:
         update(game, Entity(i))
