import gametypes, slotmap, heaparray

proc createEntity*(world: var World): Entity =
  result = world.signature.incl({})

iterator queryAll*(world: World, parent: Entity, query: set[HasComponent]): Entity =
  template hierarchy: untyped = world.hierarchy[entity.idx]

  var frontier = @[parent]
  while frontier.len > 0:
    let entity = frontier.pop()
    if world.signature[entity] * query == query:
      yield entity

    var childId = hierarchy.head
    while childId != invalidId:
      template childHierarchy: untyped = world.hierarchy[childId.idx]

      frontier.add(childId)
      childId = childHierarchy.next

template `?=`(name, value): bool = (let name = value; name != invalidId)
proc prepend*(world: var World, parentId, entity: Entity) =
  template hierarchy: untyped = world.hierarchy[entity.idx]
  template parent: untyped = world.hierarchy[parentId.idx]
  template headSibling: untyped = world.hierarchy[headSiblingId.idx]

  hierarchy.prev = invalidId
  hierarchy.next = parent.head
  if headSiblingId ?= parent.head:
    assert headSibling.prev == invalidId
    headSibling.prev = entity
  parent.head = entity

proc removeNode*(world: var World, entity: Entity) =
  template hierarchy: untyped = world.hierarchy[entity.idx]
  template parent: untyped = world.hierarchy[parentId.idx]
  template nextSibling: untyped = world.hierarchy[nextSiblingId.idx]
  template prevSibling: untyped = world.hierarchy[prevSiblingId.idx]

  if parentId ?= hierarchy.parent:
    if entity == parent.head: parent.head = hierarchy.next
  if nextSiblingId ?= hierarchy.next: nextSibling.prev = hierarchy.prev
  if prevSiblingId ?= hierarchy.prev: prevSibling.next = hierarchy.next

proc delete*(game: var Game, entity: Entity) =
  for entity in queryAll(game.world, entity, {HasHierarchy}):
    removeNode(game.world, entity)
    game.toDelete.add(entity)
  #else: game.toDelete.add(entity)

proc cleanup*(game: var Game) =
  for entity in game.toDelete.items:
    game.world.signature.del(entity)
  game.toDelete.shrink(0)

proc rmComponent*(world: var World, entity: Entity, has: HasComponent) =
  world.signature[entity].excl has
