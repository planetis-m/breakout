import game_types

proc createEntity*(game: var Game): Entity =
   for i in 0 ..< MaxEntities:
      if game.world[i] == {}:
         return Entity(i)
   raise newException(ResourceExhaustedError, "No more entities available!")

template `?=`(name, value): bool = (let name = value; name != invalidId)
proc prepend*(game: var Game, parentId, entity: Entity) =
   template hierarchy: untyped = game.hierarchy[entity]
   template parent: untyped = game.hierarchy[parentId]

   hierarchy.next = parent.head
   parent.head = entity

proc delete*(game: var Game, entity: Entity) =
   if HasHierarchy in game.world[entity]:
      template hierarchy: untyped = game.hierarchy[entity]
      template parent: untyped = game.hierarchy[parentId]

      if parentId ?= hierarchy.parent:
         if entity == parent.head: parent.head = hierarchy.next
      while childId ?= hierarchy.head:
         delete(game, childId)

   game.world[entity] = {}
