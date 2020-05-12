import game_types, vmath

const Query = {HasTransform2d, HasDraw2d}

proc sysDraw2d*(game: var Game, intrpl: float32) =
   game.canvas.setDrawColor(game.clearColor[0], game.clearColor[1], game.clearColor[2])
   game.canvas.clear()
   for i in 0 ..< MaxEntities:
      if game.world[i] * Query != {}:
         update(game, i, intrpl)

proc update(game: var Game, entity: int, intrpl: float32) =
   template transform: untyped = game.transform[entity]
   template draw2d: untyped = game.draw2d[entity]
   let width = int(draw2d.width.float32 * transform.scale.x)
   let height = int(draw2d.height.float32 * transform.scale.y)

   game.canvas.setDrawColor(draw2d.color[0], draw2d.color[1], draw2d.color[2], draw2d.color[3])
   game.canvas.fillRect((
      transform.world.m11.int32 - int32(width / 2),
      transform.world.m12.int32 - int32(height / 2),
      width.int32,
      height.int32))
