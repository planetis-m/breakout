import ".."/[gametypes, vmath]

proc updateTransformWorld(game: var Game; idx: TransformIdx; force = false) =
  template transform: untyped = game.transforms[idx.int]
  template previous: untyped = game.previous[game.transformPrevious[idx.int].int]

  let shouldUpdate = force or transform.flags.intersects({Dirty, Fresh})
  if shouldUpdate:
    if transform.flags.containsAll({Fresh}):
      transform.flags.excl(Fresh)
    else:
      previous.position = transform.world.origin
      previous.rotation = transform.world.rotation
      previous.scale = transform.world.scale
      transform.flags.incl(HasPrevious)
      transform.flags.excl(Dirty)

    let local = compose(transform.scale, transform.rotation, transform.translation)
    let hierarchyIdx = game.transformHierarchy[idx.int]
    let parent = game.hierarchies[hierarchyIdx.int].parent
    if parent != NoHierarchyIdx:
      let parentTransform = game.transforms[game.hierarchyTransform[parent.int].int]
      transform.world = parentTransform.world * local
    else:
      transform.world = local

proc updateTransformTree(game: var Game; idx: TransformIdx; force = false) =
  let subtreeDirty = force or game.transforms[idx.int].flags.intersects({Dirty, Fresh})

  game.updateTransformWorld(idx, force)

  let hierarchyIdx = game.transformHierarchy[idx.int]
  var child = game.hierarchies[hierarchyIdx.int].head
  while child != NoHierarchyIdx:
    game.updateTransformTree(game.hierarchyTransform[child.int], subtreeDirty)
    child = game.hierarchies[child.int].next

proc sysTransform2d*(game: var Game) =
  game.updateTransformTree(game.camera.transform)
