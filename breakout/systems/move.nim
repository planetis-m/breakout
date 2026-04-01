import ".."/[gametypes, vmath]

proc updateTransform(game: var Game; transformIdx: TransformIdx; moveIdx: MoveIdx) =
  let move = game.moves[moveIdx]
  if move.direction.x != 0 or move.direction.y != 0:
    template transform: untyped = game.transforms[transformIdx]
    transform.translation.x += move.direction.x * move.speed
    transform.translation.y += move.direction.y * move.speed
    transform.flags.incl(Dirty)

proc sysMove*(game: var Game) =
  game.updateTransform(game.paddle.transform, game.paddle.move)

  for ball in game.balls.items:
    if Alive in ball.flags:
      game.updateTransform(ball.transform, ball.move)

  for particle in game.particles.items:
    if Alive in particle.flags:
      game.updateTransform(particle.transform, particle.move)
