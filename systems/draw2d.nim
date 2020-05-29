import game_types, vmath

const Query = {HasTransform2d, HasPrevious, HasDraw2d}

proc update(game: var Game, entity: Entity, intrpl: float32) =
   template transform: untyped = game.transform[entity]
   template draw2d: untyped = game.draw2d[entity]
   template previous: untyped = game.previous[entity]

   let width = int32(draw2d.width.float32 * transform.scale.x)
   let height = int32(draw2d.height.float32 * transform.scale.y)

   let position = vec2(lerp(previous.world.m11, transform.world.m11, intrpl),
         lerp(previous.world.m12, transform.world.m12, intrpl))

   game.canvas.setDrawColor(draw2d.color[0], draw2d.color[1], draw2d.color[2], draw2d.color[3])
   game.canvas.fillRect((
      position.x.int32 - int32(width / 2),
      position.y.int32 - int32(height / 2),
      width.int32,
      height.int32))

proc sysDraw2d*(game: var Game, intrpl: float32) =
   game.canvas.setDrawColor(game.clearColor[0], game.clearColor[1], game.clearColor[2])
   game.canvas.clear()
   for i in 0 ..< MaxEntities:
      if game.world[i] * Query == Query:
         update(game, Entity(i), intrpl)
