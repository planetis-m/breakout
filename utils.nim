import game_types, registry, storage

proc createEntity*(game: var Game): Entity =
   game.entities.createEntity()

template `?=`(name, value): bool = (let name = value; name != invalidId)
proc prepend*(game: var Game, parentId, entity: Entity) =
   template hierarchy: untyped = game.hierarchy[entity.index]
   template parent: untyped = game.hierarchy[parentId.index]

   hierarchy.next = parent.head
   parent.head = entity

proc delete*(game: var Game, entity: Entity) =
   if HasHierarchy in game.world[entity]:
      template hierarchy: untyped = game.hierarchy[entity.index]
      template parent: untyped = game.hierarchy[parentId.index]

      if parentId ?= hierarchy.parent:
         if entity == parent.head: parent.head = hierarchy.next
      while childId ?= hierarchy.head:
         delete(game, childId)

   game.world.delete(entity)

proc rmComponent*(game: var Game, entity: Entity, has: HasComponent) =
   game.world[entity].excl has
