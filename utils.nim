import game_types

proc createEntity*(self: var Game): int =
   for i in 0 ..< MaxEntities:
      if self.world[i] == {}:
         return i
   raise newException(ResourceExhaustedError, "No more entities available!")

template `?=`(name, value): bool = (let name = value; name > -1)
proc prependNode*(game: var Game, parentId, entity: int) =
   template hierarchy: untyped = game.hierarchy[entity]
   template parent: untyped = game.hierarchy[parentId]
   template headSibling: untyped = game.hierarchy[headSiblingId]

   hierarchy.prev = -1
   hierarchy.next = parent.head
   if headSiblingId ?= parent.head:
      assert headSibling.prev == -1
      headSibling.prev = entity
   parent.head = entity

proc removeNode*(game: var Game, entity: int) =
   template hierarchy: untyped = game.hierarchy[entity]
   template parent: untyped = game.hierarchy[parentId]
   template nextSibling: untyped = game.hierarchy[nextSiblingId]
   template prevSibling: untyped = game.hierarchy[prevSiblingId]

   if parentId ?= hierarchy.parent:
      if entity == parent.head: parent.head = hierarchy.next
   if nextSiblingId ?= hierarchy.next: nextSibling.prev = hierarchy.prev
   if prevSiblingId ?= hierarchy.prev: prevSibling.next = hierarchy.next

proc delete*(self: var Game, entity: int) =
   if HasHierarchy in self.world[entity]:
      removeNode(self, entity)
   self.world[entity] = {}
