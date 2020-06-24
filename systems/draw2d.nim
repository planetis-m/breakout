import ".." / [game_types, vmath, utils, registry, storage]

const Query = {HasCurrent, HasPrevious, HasDraw2d}

proc update(game: var Game, entity: Entity, intrpl: float32) =
   template current: untyped = game.current[entity.index]
   template previous: untyped = game.previous[entity.index]
   template draw2d: untyped = game.draw2d[entity.index]

   let position = lerp(previous.position, current.position, intrpl)
   let scale = lerp(previous.scale, current.scale, intrpl)
   let rotation = lerp(previous.rotation, current.rotation, intrpl)

   let width = int32(draw2d.width.float32 * scale.x)
   let height = int32(draw2d.height.float32 * scale.y)

   game.canvas.setDrawColor(draw2d.color[0], draw2d.color[1], draw2d.color[2], draw2d.color[3])
   game.canvas.fillRect((
      position.x.int32 - int32(width / 2),
      position.y.int32 - int32(height / 2),
      width.int32,
      height.int32))

proc sysDraw2d*(game: var Game, intrpl: float32) =
   game.canvas.setDrawColor(game.clearColor[0], game.clearColor[1], game.clearColor[2])
   game.canvas.clear()
   for (entity, has) in game.world.pairs:
      if has * Query == Query:
         update(game, entity, intrpl)
