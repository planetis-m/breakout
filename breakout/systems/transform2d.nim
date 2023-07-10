import ".." / [gametypes, heaparrays, vmath, mixins, utils, slottables]

const Query = {HasTransform2d, HasHierarchy, HasDirty}

proc update(world: var World, entity: Entity) =
  template `?=`(name, value): bool = (let name = value; name != InvalidId)
  template transform: untyped = world.transform[entity.idx]
  template hierarchy: untyped = world.hierarchy[entity.idx]

  if HasFresh notin world.signature[entity]:
    let position = transform.world.origin
    let rotation = transform.world.rotation
    let scale = transform.world.scale

    world.mixPrevious(entity, position, rotation, scale)
    world.rmComponent(entity, HasDirty)
  else:
    world.rmComponent(entity, HasFresh)

  let local = compose(transform.scale, transform.rotation, transform.translation)
  if parentId ?= hierarchy.parent:
    template parentTransform: untyped = world.transform[parentId.idx]
    transform.world = parentTransform.world * local
  else:
    transform.world = local

proc sysTransform2d*(game: var Game) =
  for entity in queryAll(game.world, game.camera, Query):
    update(game.world, entity)
