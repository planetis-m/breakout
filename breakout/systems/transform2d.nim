import ".."/[gametypes, vmath]

proc updateTransformWorld(game: var Game; idx: TransformIdx; force = false) =
  template transform: untyped = game.transforms[idx.int]

  let shouldUpdate = force or transform.flags.intersects({Dirty, Fresh})
  if shouldUpdate:
    if transform.flags.containsAll({Fresh}):
      transform.flags.excl(Fresh)
    else:
      let position = transform.world.origin
      let rotation = transform.world.rotation
      let scale = transform.world.scale
      transform.previousPosition = position
      transform.previousRotation = rotation
      transform.previousScale = scale
      transform.flags.incl(HasPrevious)
      transform.flags.excl(Dirty)

    let local = compose(transform.scale, transform.rotation, transform.translation)
    let parent = game.hierarchies[idx.int].parent
    if parent != NoTransformIdx:
      let parentTransform = game.transforms[parent.int]
      transform.world = parentTransform.world * local
    else:
      transform.world = local

proc updateTransformTree(game: var Game; idx: TransformIdx; force = false) =
  let subtreeDirty = force or game.transforms[idx.int].flags.intersects({Dirty, Fresh})

  game.updateTransformWorld(idx, force)

  var child = game.hierarchies[idx.int].head
  while child != NoTransformIdx:
    game.updateTransformTree(child, subtreeDirty)
    child = game.hierarchies[child.int].next

proc sysTransform2d*(game: var Game) =
  game.updateTransformTree(game.camera.transform)
