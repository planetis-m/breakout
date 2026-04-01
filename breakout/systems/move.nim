import ".."/gamecore

proc moveNode(game: var Game; node: NodeIdx; move: Move) =
  if move.direction.x != 0 or move.direction.y != 0:
    template transform: untyped = game.nodes[node.int].transform
    transform.translation.x += move.direction.x * move.speed
    transform.translation.y += move.direction.y * move.speed
    game.markDirty(node)

proc movePaddle(game: var Game) =
  if game.paddle.node != NoNodeIdx:
    game.moveNode(game.paddle.node, game.paddle.move)

proc moveBalls(game: var Game) =
  for ball in game.balls.items:
    game.moveNode(ball.node, ball.move)

proc moveParticles(game: var Game) =
  for particle in game.particles.items:
    game.moveNode(particle.node, particle.move)

proc sysMove*(game: var Game) =
  game.movePaddle()
  game.moveBalls()
  game.moveParticles()
