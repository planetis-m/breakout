import ".."/gamecore

proc moveNode(game: var Game; node: NodeIdx; move: Move) =
  if move.direction.x != 0 or move.direction.y != 0:
    template transform: untyped = game.transforms[node.int]
    transform.translation.x += move.direction.x * move.speed
    transform.translation.y += move.direction.y * move.speed
    game.markDirty(node)

proc movePaddle(game: var Game) =
  if game.paddle.node != NoNodeIdx:
    game.moveNode(game.paddle.node, game.moves[game.paddle.move.int])

proc moveBalls(game: var Game) =
  for ball in game.balls.items:
    game.moveNode(ball.node, game.moves[ball.move.int])

proc moveParticles(game: var Game) =
  for particle in game.particles.items:
    game.moveNode(particle.node, game.moves[particle.move.int])

proc sysMove*(game: var Game) =
  game.movePaddle()
  game.moveBalls()
  game.moveParticles()
