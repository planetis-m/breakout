import ".."/gametypes

proc updateFading(game: var Game; transformIdx: TransformIdx; drawIdx: Draw2dIdx;
    fadeIdx: FadeIdx; alive: var bool) =
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
      alive = false

proc cleanupDead*(game: var Game) =
  for i in countdown(game.actors.high, 0):
    if not game.actors[i].alive:
      game.removeActor(ActorIdx(i))

proc sysFade*(game: var Game) =
  for actor in mitems(game.actors):
    if actor.alive and actor.fade != NoFadeIdx:
      game.updateFading(actor.transform, actor.draw2d, actor.fade, actor.alive)
