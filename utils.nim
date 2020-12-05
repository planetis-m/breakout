import game_types, registry, storage

proc createEntity*(world: var World): Entity =
   result = world.registry.createEntity()
   world.signature[result] = {}

iterator queryAll*(world: World, parent: Entity, query: set[HasComponent]): Entity =
   var frontier: seq[Entity] = @[parent]
   while frontier.len > 0:
      let entity = frontier.pop()
      if world.signature[entity] * query == query:
         yield entity

      template hierarchy: untyped = world.hierarchy[entity.index]
      var childId = hierarchy.head
      while childId != invalidId:
         template childHierarchy: untyped = world.hierarchy[childId.index]

         frontier.add(childId)
         childId = childHierarchy.next

template `?=`(name, value): bool = (let name = value; name != invalidId)
proc prepend*(world: var World, parentId, entity: Entity) =
   template hierarchy: untyped = world.hierarchy[entity.index]
   template parent: untyped = world.hierarchy[parentId.index]
   template headSibling: untyped = world.hierarchy[headSiblingId.index]

   hierarchy.prev = invalidId
   hierarchy.next = parent.head
   if headSiblingId ?= parent.head:
      assert headSibling.prev == invalidId
      headSibling.prev = entity
   parent.head = entity

proc removeNode*(world: var World, entity: Entity) =
   template hierarchy: untyped = world.hierarchy[entity.index]
   template parent: untyped = world.hierarchy[parentId.index]
   template nextSibling: untyped = world.hierarchy[nextSiblingId.index]
   template prevSibling: untyped = world.hierarchy[prevSiblingId.index]

   if parentId ?= hierarchy.parent:
      if entity == parent.head: parent.head = hierarchy.next
   if nextSiblingId ?= hierarchy.next: nextSibling.prev = hierarchy.prev
   if prevSiblingId ?= hierarchy.prev: prevSibling.next = hierarchy.next

proc delete*(game: var Game, entity: Entity) =
   if HasHierarchy in game.world.signature[entity]:
      template hierarchy: untyped = game.world.hierarchy[entity.index]
      removeNode(game.world, entity)

      var childId = hierarchy.head
      while childId != invalidId:
         template childHierarchy: untyped = game.world.hierarchy[childId.index]

         delete(game, childId)
         childId = childHierarchy.next

   game.toDelete.add(entity)

proc cleanup*(game: var Game) =
   for entity in game.toDelete.items:
      game.world.signature.delete(entity)
      game.world.registry.delete(entity)

   game.toDelete.shrink(0)

proc rmComponent*(world: var World, entity: Entity, has: HasComponent) =
   world.signature[entity].excl has
