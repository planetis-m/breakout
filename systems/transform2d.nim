import ".." / [game_types, sparse_set, vmath, dsl]

const Query = {HasTransform2d, HasHierarchy, HasDirty}

proc update(game: var Game, entity: Entity) =
   template `?=`(name, value): bool = (let name = value; name != invalidId)
   template transform: untyped = game.transform[entity]
   template hierarchy: untyped = game.hierarchy[entity]
   template previous: untyped = game.previous[entity]

   var childId = hierarchy.head
   while childId != invalidId:
      template childHierarchy: untyped = game.hierarchy[childId]

      game.mixDirty(childId)
      childId = childHierarchy.next

   game.rmDirty(entity)

   if HasPrevious notin game.world[entity]:
      game.mixPrevious(entity, transform.world)

   let local = compose(transform.translation, transform.scale, transform.rotation)
   if parentId ?= hierarchy.parent:
      template parentTransform: untyped = game.transform[parentId]
      transform.world = parentTransform.world * local
   else:
      transform.world = local

proc sysTransform2d*(game: var Game) =
   for i in 0 ..< MaxEntities:
      if game.world[i] * Query == Query:
         update(game, Entity(i))
