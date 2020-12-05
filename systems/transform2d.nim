import ".." / [game_types, vmath, mixins, utils, registry, storage], std/sugar

proc update(game: var Game, entity: Entity, dirty: var seq[Entity]) =
   template `?=`(name, value): bool = (let name = value; name != invalidId)
   template transform: untyped = game.transform[entity.index]
   template hierarchy: untyped = game.hierarchy[entity.index]

   if entity.index == 192:
      echo "sysTransform2d.update ", game.tickId, " ", isValid(entity, game.entities), " ", entity.version
      echo entity in game.world
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
        echo "sysTransform.addChildren ", isValid(childId, game.entities), " ", game.world[childId]
      dirty.add(childId)
      childId = childHierarchy.next

   let local = compose(transform.scale, transform.rotation, transform.translation)
   if parentId ?= hierarchy.parent:
      template parentTransform: untyped = game.transform[parentId.index]
      transform.world = parentTransform.world * local
   else:
      transform.world = local

proc selectionSort(s: var openarray[Entity]; c: openarray[Hierarchy];
      pred: proc(x: Hierarchy, y: Entity): bool) =
   for i in 0 ..< len(s):
      var minIndex = i
      var minVal = s[i]
      # searches for the smallest of all following items
      for j in i + 1 ..< len(s):
         if pred(c[minVal.index], s[j]):
            minIndex = j
            minVal = s[j]
      swap(s[i], s[minIndex])

proc sysTransform2d*(game: var Game) =
   selectionSort(game.dirty, game.hierarchy, (x, y) => x.parent == y)

   var dirty: seq[Entity]
   for entity in game.dirty:
      update(game, entity, dirty)
      if entity.index == 192:
         echo "sysTransform2d.sort ", game.tickId, " ", game.draw2d[entity.index].color
         echo game.world[entity]
   game.dirty = dirty
