import math
import ".."/[gametypes, raylib, vmath]

const Tolerance = 0.75'f32

proc drawTransform(game: Game; transformIdx: TransformIdx; drawIdx: Draw2dIdx;
    intrpl: float32) =
  let transform = game.transforms[transformIdx.int]
  if HasPrevious notin transform.flags:
    return

  let previous = game.previous[game.transformPrevious[transformIdx.int].int]
  let position = lerp(previous.position, transform.world.origin, intrpl)
  let scale = lerp(previous.scale, transform.world.scale, intrpl)
  let draw2d = game.drawables[drawIdx.int]

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
  game.drawTransform(game.paddle.transform, game.paddle.draw2d, intrpl)

  for ball in game.balls.items:
    if Alive in ball.flags:
      game.drawTransform(ball.transform, ball.draw2d, intrpl)

  for brick in game.bricks.items:
    if Alive in brick.flags:
      game.drawTransform(brick.transform, brick.draw2d, intrpl)

  for particle in game.particles.items:
    if Alive in particle.flags:
      game.drawTransform(particle.transform, particle.draw2d, intrpl)

  for trail in game.trails.items:
    if Alive in trail.flags:
      game.drawTransform(trail.transform, trail.draw2d, intrpl)
