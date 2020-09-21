import ".." / [game_types, vmath, mixins, utils, registry, storage]

const Query = {HasTransform2d, HasHierarchy, HasDirty}

proc update(game: var Game, entity: Entity) =
   template `?=`(name, value): bool = (let name = value; name != invalidId)
   template transform: untyped = game.transform[entity.index]
   template hierarchy: untyped = game.hierarchy[entity.index]

   var childId = hierarchy.head
   while childId != invalidId:
      template childHierarchy: untyped = game.hierarchy[childId.index]

      game.mixDirty(childId)
      childId = childHierarchy.next

   game.rmComponent(entity, HasDirty)

   let position = transform.world.origin
   let rotation = transform.world.rotation
   let scale = transform.world.scale

   game.mixPrevious(entity, position, rotation, scale)

   #template previous: untyped = game.previous[entity.index]
   #echo "Transform Entity: ", entity.index
   #echo "  Comp: ", game.world[entity]
   #echo "  Previous: ", previous.position.Vec2
   #echo "  Transform ", position.Vec2

   let local = compose(transform.translation, transform.rotation, transform.scale)
   if parentId ?= hierarchy.parent:
      template parentTransform: untyped = game.transform[parentId.index]
      transform.world = parentTransform.world * local
   else:
      transform.world = local

proc sysTransform2d*(game: var Game) =
   for (entity, has) in game.world.pairs:
      if has * Query == Query:
         update(game, entity)
