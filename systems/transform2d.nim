import ".." / [game_types, vmath, mixins, utils, registry, storage]

const Query = {HasCurrent, HasTransform2d, HasHierarchy, HasDirty}

proc update(game: var Game, entity: Entity) =
   template `?=`(name, value): bool = (let name = value; name != invalidId)
   template transform: untyped = game.transform[entity.index]
   template hierarchy: untyped = game.hierarchy[entity.index]
   template current: untyped = game.current[entity.index]

   var childId = hierarchy.head
   while childId != invalidId:
      template childHierarchy: untyped = game.hierarchy[childId.index]

      game.mixDirty(childId)
      childId = childHierarchy.next

   game.rmComponent(entity, HasDirty)
   game.mixPrevious(entity, current.position, current.scale, current.rotation)

   let local = compose(transform.translation, transform.rotation, transform.scale)
   if parentId ?= hierarchy.parent:
      template parentCurrent: untyped = game.current[parentId.index]
      current.world = parentCurrent.world * local
   else:
      current.world = local

   current.position = current.world.origin
   current.scale = current.world.scale
   current.rotation = current.world.rotation

proc sysTransform2d*(game: var Game) =
   for (entity, has) in game.world.pairs:
      if has * Query == Query:
         update(game, entity)
