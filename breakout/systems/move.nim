import ".."/[gametypes, vmath]

proc updateTransform(game: var Game; transformIdx: TransformIdx; moveIdx: MoveIdx) =
  let move = game.moves[moveIdx]
  if move.direction.x != 0 or move.direction.y != 0:
    template transform: untyped = game.transforms[transformIdx]
    transform.translation.x += move.direction.x * move.speed
    transform.translation.y += move.direction.y * move.speed
    transform.flags.incl(Dirty)

proc sysMove*(game: var Game) =
  for actor in game.actors.items:
    if actor.alive and actor.move != NoMoveIdx and
        actor.kind in {PaddleKind, BallKind, ParticleKind}:
      game.updateTransform(actor.transform, actor.move)
