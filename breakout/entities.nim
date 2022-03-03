type
  Entity* = distinct EntityImpl
  EntityImpl* = uint16

const
  versionBits = 3
  versionMask = 1 shl versionBits - 1
  indexBits = sizeof(Entity) * 8 - versionBits
  indexMask = 1 shl indexBits - 1
  invalidId* = Entity(indexMask) # a sentinel value to represent an invalid entity
  maxEntities* = indexMask

template idx*(e: Entity): int = e.int and indexMask
template version*(e: Entity): EntityImpl = e.EntityImpl shr indexBits
template toEntity*(idx, v: EntityImpl): Entity = Entity(v shl indexBits or idx)

proc `==`*(a, b: Entity): bool {.borrow.}
proc `$`*(e: Entity): string =
  "Entity(i: " & $e.idx & ", v: " & $e.version & ")"
