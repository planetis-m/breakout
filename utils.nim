import game_types

proc createEntity*(game: var Game): Entity =
   for i in 0 ..< MaxEntities:
      if game.world[i] == {}:
         return Entity(i)
   raise newException(ResourceExhaustedError, "No more entities available!")

template `?=`(name, value): bool = (let name = value; name > -1)
proc prependNode*(game: var Game, parentId, entity: Entity) =
   template hierarchy: untyped = game.hierarchy[entity]
   template parent: untyped = game.hierarchy[parentId]
   template headSibling: untyped = game.hierarchy[headSiblingId]

   hierarchy.prev = -1
   hierarchy.next = parent.head
   if headSiblingId ?= parent.head:
      assert headSibling.prev == -1
      headSibling.prev = entity
   parent.head = entity

proc removeNode*(game: var Game, entity: Entity) =
   template hierarchy: untyped = game.hierarchy[entity]
   template parent: untyped = game.hierarchy[parentId]
   template nextSibling: untyped = game.hierarchy[nextSiblingId]
   template prevSibling: untyped = game.hierarchy[prevSiblingId]

   if parentId ?= hierarchy.parent:
      if entity == parent.head: parent.head = hierarchy.next
   if nextSiblingId ?= hierarchy.next: nextSibling.prev = hierarchy.prev
   if prevSiblingId ?= hierarchy.prev: prevSibling.next = hierarchy.next

proc delete*(game: var Game, entity: Entity) =
   if HasHierarchy in game.world[entity]:
      removeNode(game, entity)
   game.world[entity] = {}
