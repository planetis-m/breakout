import math
import ".."/[gametypes, raylib, vmath]

const
  Tolerance = 0.75'f32

proc drawTransform(game: Game; node: NodeIdx; draw: Draw2d; intrpl: float32) =
  template transformNode: untyped = game.nodes[node.int]
  template transform: untyped = transformNode.transform
  template previous: untyped = transformNode.previous

  if not transformNode.active or HasPrevious notin transform.flags:
    return

  let position = lerp(previous.position, transform.world.origin, intrpl)
  let scale = lerp(previous.scale, transform.world.scale, intrpl)

  let width = int32(draw.width.float32 * scale.x)
  let height = int32(draw.height.float32 * scale.y)

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
    draw.color
  )

proc sysDraw2d*(game: var Game; intrpl: float32) =
  clearBackground(game.clearColor)

  if game.paddle.active:
    game.drawTransform(game.paddle.node, game.paddle.draw, intrpl)

  for ball in game.balls.items:
    game.drawTransform(ball.node, ball.draw, intrpl)

  for brick in game.bricks.items:
    if not brick.dead:
      game.drawTransform(brick.node, brick.draw, intrpl)

  for particle in game.particles.items:
    if not particle.dead:
      game.drawTransform(particle.node, particle.draw, intrpl)

  for trail in game.trails.items:
    if not trail.dead:
      game.drawTransform(trail.node, trail.draw, intrpl)
