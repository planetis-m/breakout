import ".."/[gametypes, vmath]

proc updateTransform(game: var Game; transformIdx: TransformIdx; moveIdx: MoveIdx) =
  let move = game.moves[moveIdx.int]
  if move.direction.x != 0 or move.direction.y != 0:
    template transform: untyped = game.transforms[transformIdx.int]
    transform.translation.x += move.direction.x * move.speed
    transform.translation.y += move.direction.y * move.speed
    transform.dirty = true

proc sysMove*(game: var Game) =
  game.updateTransform(game.paddle.transform, game.paddle.move)

  for ball in game.balls.items:
    if ball.alive:
      game.updateTransform(ball.transform, ball.move)

  for particle in game.particles.items:
    if particle.alive:
      game.updateTransform(particle.transform, particle.move)
