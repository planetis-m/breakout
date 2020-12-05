import ".." / [game_types, vmath, mixins, utils, registry, storage]

proc update(game: var Game, entity: Entity, dirty: var seq[Entity]) =
   template `?=`(name, value): bool = (let name = value; name != invalidId)
   template transform: untyped = game.transform[entity.index]
   template hierarchy: untyped = game.hierarchy[entity.index]

   if HasFresh notin game.world[entity]:
      let position = transform.world.origin
      let rotation = transform.world.rotation
      let scale = transform.world.scale

      game.mixPrevious(entity, position, rotation, scale)
   else:
      dirty.add(entity)
      game.rmComponent(entity, HasFresh)

   var childId = hierarchy.head
   while childId != invalidId:
      template childHierarchy: untyped = game.hierarchy[childId.index]
      if HasTransform2d notin game.world[childId]:
        echo isValid(childId, game.entities), " ", game.world[childId]
      dirty.add(childId)
      childId = childHierarchy.next

   let local = compose(transform.scale, transform.rotation, transform.translation)
   if parentId ?= hierarchy.parent:
      template parentTransform: untyped = game.transform[parentId.index]
      transform.world = parentTransform.world * local
   else:
      transform.world = local

proc sysTransform2d*(game: var Game) =
   template hierarchy: untyped = game.hierarchy[entity.index]

   var dirty: seq[Entity]
   for i in 0 .. game.dirty.high:
      var entity = game.dirty[i]
      var minIndex = i
      for j in i + 1 .. game.dirty.high:
         if hierarchy.parent == game.dirty[j]:
            minIndex = j
            entity = game.dirty[j]
      game.dirty[minIndex] = game.dirty[i]
      update(game, entity, dirty)
   game.dirty = dirty
