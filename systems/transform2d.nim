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

      dirty.add(childId)
      childId = childHierarchy.next

   let local = compose(transform.scale, transform.rotation, transform.translation)
   if parentId ?= hierarchy.parent:
      template parentTransform: untyped = game.transform[parentId.index]
      transform.world = parentTransform.world * local
   else:
      transform.world = local

proc sysTransform2d*(game: var Game) =
   var dirty: seq[Entity]
   for i in 1 .. game.dirty.high:
      let entity = game.dirty[i]
      var j = i - 1
      while j >= 0 and game.hierarchy[game.dirty[j].index].parent == entity:
         game.dirty[j + 1] = game.dirty[j]
         dec(j)
      game.dirty[j + 1] = entity
   for i in 0 .. game.dirty.high:
      update(game, game.dirty[i], dirty)
   game.dirty = dirty
