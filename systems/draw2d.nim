import math, sdl2, ".." / [game_types, vmath, registry, storage]

const Query = {HasCurrent, HasDraw2d}
const Tolerance = 0.75'f32

proc update(game: var Game, entity: Entity) =
   template current: untyped = game.current[entity.index]
   template draw2d: untyped = game.draw2d[entity.index]

   let width = int32(draw2d.width.float32 * current.scale.x)
   let height = int32(draw2d.height.float32 * current.scale.y)

   var x = current.position.x.int32
   var y = current.position.y.int32
   if abs(current.position.x - x.float32) > Tolerance: x = ceil(current.position.x).int32
   if abs(current.position.y - y.float32) > Tolerance: y = ceil(current.position.y).int32

   var rectangle = (
      x - int32(width / 2),
      y - int32(height / 2),
      width.int32,
      height.int32)
   game.renderer.setDrawColor(draw2d.color[0], draw2d.color[1], draw2d.color[2], draw2d.color[3])
   game.renderer.fillRect(rectangle)

proc sysDraw2d*(game: var Game) =
   game.renderer.setDrawColor(game.clearColor[0], game.clearColor[1], game.clearColor[2])
   game.renderer.clear()
   for (entity, has) in game.world.pairs:
      if has * Query == Query:
         update(game, entity)
