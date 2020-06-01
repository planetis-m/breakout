import ".." / [game_types, sparse_set, vmath, dsl]

const Query = {HasTransform2d, HasPrevious, HasHierarchy, HasDirty}

proc update(game: var Game, entity: Entity, isFirst: bool) =
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

   let self = compose(transform.translation, transform.rotation, transform.scale)
   if isFirst: previous.world = transform.world

   if parentId ?= hierarchy.parent:
      template parentTransform: untyped = game.transform[parentId]
      transform.world = parentTransform.world * self
   else:
      transform.world = self

proc sysTransform2d*(game: var Game, isFirst: bool) =
   for i in 0 ..< MaxEntities:
      if game.world[i] * Query == Query:
         update(game, Entity(i), isFirst)
