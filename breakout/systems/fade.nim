import ".."/gametypes

proc updateFading(game: var Game; transformIdx: TransformIdx; drawIdx: Draw2dIdx;
    fadeIdx: FadeIdx; kind: var ActorKind) =
  template transform: untyped = game.transforms[transformIdx]
  template draw: untyped = game.drawables[drawIdx]
  let fade = game.fades[fadeIdx]

  if draw.color[3] > 0:
    let step = 255 * fade.step
    draw.color[3] = draw.color[3] - step.uint8
    transform.scale.x -= fade.step
    transform.scale.y -= fade.step
    transform.flags.incl(Dirty)

    if transform.scale.x <= 0:
      kind = DeadKind

proc cleanupDead*(game: var Game) =
  for i in countdown(game.actors.high, 0):
    if game.actors[i].kind == DeadKind:
      game.removeActor(ActorIdx(i))

proc sysFade*(game: var Game) =
  for actor in mitems(game.actors):
    if actor.kind != DeadKind and actor.fade != NoFadeIdx:
      game.updateFading(actor.transform, actor.draw2d, actor.fade, actor.kind)
