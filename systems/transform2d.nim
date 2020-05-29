import ../game_types, ../sparse_set, ../vmath

const Query = {HasTransform2d, HasPrevious, HasHierarchy}

proc update(game: var Game, entity: Entity, isFirst: bool) =
   template `?=`(name, value): bool = (let name = value; name != invalidId)
   template transform: untyped = game.transform[entity]
   template hierarchy: untyped = game.hierarchy[entity]
   template previous: untyped = game.previous[entity]

   if transform.dirty:
      var childEntityId = hierarchy.head
      while childEntityId != invalidId:
         template childTransform: untyped = game.transform[childEntityId]
         template childHierarchy: untyped = game.hierarchy[childEntityId]

         childTransform.dirty = true
         childEntityId = childHierarchy.next

      transform.dirty = false

      let translated = fromTranslation(transform.translation)
      let translatedAndRotaded = rotate(translated, transform.rotation)
      let translatedRotatedAndScaled = scale(translatedAndRotaded, transform.scale)

      if isFirst: previous.world = transform.world

      if parentId ?= hierarchy.parent:
         template parentTransform: untyped = game.transform[parentId]
         transform.world = parentTransform.world * translatedRotatedAndScaled
      else:
         transform.world = translatedRotatedAndScaled

      transform.self = invert(transform.world)

proc sysTransform2d*(game: var Game, isFirst: bool) =
   for i in 0 ..< MaxEntities:
      if game.world[i] * Query == Query:
         update(game, Entity(i), isFirst)
