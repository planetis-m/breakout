import game_types, vmath

const Query = {HasHierarchy, HasMove, HasPredict, HasTransform2d}

proc sysPredict*(game: var Game, intrpl: float32) =
   for i in 0 ..< MaxEntities:
      if game.world[i] * Query != {}:
         update(game, i, intrpl)

proc update(game: var Game, entity: int, intrpl: float32) =
   template `?=`(name, value): bool = (let name = value; name != -1)
   template hierarchy: untyped = game.hierarchy[entity]
   template move: untyped = game.move[entity]
   template predict: untyped = game.predict[entity]
   template transform: untyped = game.transform[entity]

   var translation = transform.translation
   if move.direction.x != 0.0 or move.direction.y != 0.0:
      translation.x += move.direction.x * move.speed * intrpl
      translation.y += move.direction.y * move.speed * intrpl

      predict.dirty = true

   if predict.dirty:
      var childEntityId = hierarchy.head
      while childEntityId != -1:
         template childPredict: untyped = game.predict[childEntityId]
         template childHierarchy: untyped = game.hierarchy[childEntityId]

         childPredict.dirty = true
         childEntityId = childHierarchy.next

      predict.dirty = false

      let translated = fromTranslation(translation)
      let translatedAndRotaded = rotate(translated, transform.rotation)
      let translatedRotatedAndScaled = scale(translatedAndRotaded, transform.scale)

      if parentId ?= hierarchy.parent:
         template parentPredict: untyped = game.predict[parentId]
         predict.world = parentPredict.world * translatedRotatedAndScaled
      else:
         predict.world = translatedRotatedAndScaled
