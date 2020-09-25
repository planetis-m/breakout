import ".." / [game_types, vmath, mixins, utils, registry, storage]

const Query = {HasTransform2d, HasHierarchy, HasDirty}

proc update(game: var Game, entity: Entity) =
   template `?=`(name, value): bool = (let name = value; name != invalidId)
   template transform: untyped = game.transform[entity.index]
   template hierarchy: untyped = game.hierarchy[entity.index]

   var childId = hierarchy.head
   while childId != invalidId:
      template childHierarchy: untyped = game.hierarchy[childId.index]

      game.mixDirty(childId)
      childId = childHierarchy.next

   game.rmComponent(entity, HasDirty)

   if HasNewlyCreated notin game.world[entity]:
      let position = transform.world.origin
      let rotation = transform.world.rotation
      let scale = transform.world.scale

      game.mixPrevious(entity, position, rotation, scale)

   let local = compose(transform.scale, transform.rotation, transform.translation)
   if parentId ?= hierarchy.parent:
      template parentTransform: untyped = game.transform[parentId.index]
      transform.world = parentTransform.world * local
   else:
      transform.world = local

   if HasNewlyCreated in game.world[entity]:
      let position = transform.world.origin
      let rotation = transform.world.rotation
      let scale = transform.world.scale

      game.mixCurrent(entity, position, rotation, scale)
      game.rmComponent(entity, HasNewlyCreated)

proc sysTransform2d*(game: var Game) =
   for (entity, has) in game.world.pairs:
      if has * Query == Query:
         update(game, entity)
