import game_types, registry, storage

proc createEntity*(game: var Game): Entity =
   result = game.entities.createEntity()
   game.world[result] = {}

iterator queryAll*(game: Game, parent: Entity, query: set[HasComponent]): Entity =
   var frontier: seq[Entity] = @[parent]
   while frontier.len > 0:
      let entity = frontier.pop()
      if game.world[entity] * query == query:
         yield entity

      template hierarchy: untyped = game.hierarchy[entity.index]
      var childId = hierarchy.head
      while childId != invalidId:
         template childHierarchy: untyped = game.hierarchy[childId.index]

         frontier.add(childId)
         childId = childHierarchy.next

template `?=`(name, value): bool = (let name = value; name != invalidId)
proc prepend*(game: var Game, parentId, entity: Entity) =
   template hierarchy: untyped = game.hierarchy[entity.index]
   template parent: untyped = game.hierarchy[parentId.index]
   template headSibling: untyped = game.hierarchy[headSiblingId.index]

   hierarchy.prev = invalidId
   hierarchy.next = parent.head
   if headSiblingId ?= parent.head:
      assert headSibling.prev == invalidId
      headSibling.prev = entity
   parent.head = entity

proc removeNode*(game: var Game, entity: Entity) =
   template hierarchy: untyped = game.hierarchy[entity.index]
   template parent: untyped = game.hierarchy[parentId.index]
   template nextSibling: untyped = game.hierarchy[nextSiblingId.index]
   template prevSibling: untyped = game.hierarchy[prevSiblingId.index]

   if parentId ?= hierarchy.parent:
      if entity == parent.head: parent.head = hierarchy.next
   if nextSiblingId ?= hierarchy.next: nextSibling.prev = hierarchy.prev
   if prevSiblingId ?= hierarchy.prev: prevSibling.next = hierarchy.next

proc delete*(game: var Game, entity: Entity) =
   if HasHierarchy in game.world[entity]:
      template hierarchy: untyped = game.hierarchy[entity.index]
      removeNode(game, entity)

      var childId = hierarchy.head
      while childId != invalidId:
         template childHierarchy: untyped = game.hierarchy[childId.index]

         delete(game, childId)
         childId = childHierarchy.next

   game.toDelete.add(entity)

proc cleanup*(game: var Game) =
   for entity in game.toDelete.items:
      game.world.delete(entity)
      game.entities.delete(entity)

   game.toDelete.shrink(0)

proc rmComponent*(game: var Game, entity: Entity, has: HasComponent) =
   game.world[entity].excl has
