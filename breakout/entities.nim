type
  Entity* = distinct EntityImpl
  EntityImpl* = uint16

const
  VersionBits = 3
  IndexBits = sizeof(Entity) * 8 - VersionBits
  IndexMask = 1 shl IndexBits - 1
  InvalidId* = Entity(IndexMask) # a sentinel value to represent an invalid entity
  MaxEntities* = IndexMask

template idx*(e: Entity): int = e.int and IndexMask
template version*(e: Entity): EntityImpl = e.EntityImpl shr IndexBits
template toEntity*(idx, v: EntityImpl): Entity = Entity(v shl IndexBits or idx)

proc `==`*(a, b: Entity): bool {.borrow.}
proc `$`*(e: Entity): string =
  "Entity(i: " & $e.idx & ", v: " & $e.version & ")"
