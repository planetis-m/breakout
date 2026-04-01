import math
import ".."/[gametypes, raylib, vmath]

const Tolerance = 0.75'f32

proc drawTransform(game: Game; transformIdx: TransformIdx; drawIdx: Draw2dIdx;
    intrpl: float32) =
  let transform = game.transforms[transformIdx]
  if not transform.flags.containsAll({HasPrevious}):
    return

  let previous = game.transforms.previous(transformIdx)
  let position = lerp(previous.position, transform.world.origin, intrpl)
  let scale = lerp(previous.scale, transform.world.scale, intrpl)
  let draw2d = game.drawables[drawIdx]

  let width = int32(draw2d.width.float32 * scale.x)
  let height = int32(draw2d.height.float32 * scale.y)

  var x = position.x.int32
  var y = position.y.int32
  if abs(position.x - x.float32) > Tolerance:
    x = ceil(position.x).int32
  if abs(position.y - y.float32) > Tolerance:
    y = ceil(position.y).int32

  drawRectangle(
    x - int32(width / 2),
    y - int32(height / 2),
    width,
    height,
    draw2d.color
  )

proc sysDraw2d*(game: var Game; intrpl: float32) =
  clearBackground(game.clearColor)
  for actor in game.actors.items:
    if actor.alive and actor.draw2d != NoDraw2dIdx:
      game.drawTransform(actor.transform, actor.draw2d, intrpl)
