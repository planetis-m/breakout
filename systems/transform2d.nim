import game_types, vmath

const Query = {HasTransform2d, HasHierarchy}

proc sysTransform2d*(game: var Game) =
   for i in 0 ..< MaxEntities:
      if game.world[i] * Query != {}:
         update(game, i)

proc update(game: var Game, entity: int) =
   template `?=`(name, value): bool = (let name = value; name != -1)
   template transform: untyped = game.transform[entity]
   template hierarchy: untyped = game.hierarchy[entity]

   if transform.dirty:
      var childEntityId = hierarchy.head
      while childEntityId != -1:
         template childTransform: untyped = game.transform[childEntityId]
         template childHierarchy: untyped = game.hierarchy[childEntityId]

         childTransform.dirty = true
         childEntityId = childHierarchy.next

      transform.dirty = false

      let translated = fromTranslation(transform.translation)
      let translatedAndRotaded = rotate(translated, transform.rotation)
      let translatedRotatedAndScaled = scale(translatedAndRotaded, transform.scale)

      if parentId ?= hierarchy.parent:
         template parentTransform: untyped = game.transform[parentId]
         transform.world = parentTransform.world * translatedRotatedAndScaled
      else:
         transform.world = translatedRotatedAndScaled

      transform.self = invert(transform.world)
