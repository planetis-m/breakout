import bingo, std / streams

type
  EntityImpl* = uint16
  Entity* = distinct EntityImpl

const
  versionBits = 2
  versionMask = 1 shl versionBits - 1
  indexBits = sizeof(Entity) * 8 - versionBits
  indexMask = 1 shl indexBits - 1
  invalidId* = Entity(indexMask) ## a sentinel value to represent an invalid entity
  maxEntities* = indexMask

type
  Registry* = object
    len: int
    data: array[maxEntities, Entity]
    next: Entity

proc `==`*(a, b: Entity): bool {.borrow.}
proc toEntity(index, v: EntityImpl): Entity =
  result = Entity(v shl indexBits or index)
proc index*(self: Entity): EntityImpl {.inline.} =
  result = self.EntityImpl and indexMask
proc version*(self: Entity): EntityImpl {.inline.} =
  result = self.EntityImpl shr indexBits and versionMask
proc `$`*(x: Entity): string =
  "Entity(i: " & $x.index & ", v: " & $x.version & ")"

proc initRegistry*(): Registry =
  result = Registry(next: invalidId)

proc isValid*(entity: Entity; r: Registry): bool =
  ## Checks if an entity identifier refers to a valid entity.
  let i = entity.index
  result = i.int < r.len and r.data[i] == entity

proc createEntity*(r: var Registry): Entity =
  ## Creates a new entity and returns it.
  ## There are two kinds of possible entity identifiers:
  ##
  ## Newly created ones in case no entities have been previously destroyed.
  ## Recycled ones with updated versions.
  if r.next == invalidId:
    assert r.len < maxEntities, "No more entities available!"
    result = Entity(r.len)
    r.data[r.len] = result
    r.len.inc
  else:
    let i = r.next.EntityImpl
    let version = r.data[i].version
    r.next = Entity(r.data[i].index)
    result = toEntity(i, version)
    r.data[i] = result

proc delete*(r: var Registry; entity: Entity) =
  ## When an entity is destroyed, its version is updated and the identifier
  ## can be recycled at any time.
  let i = entity.index
  if i.int < r.len and r.data[i] == entity:
    # lengthens the implicit list of next entities
    r.data[i] = toEntity(r.next.EntityImpl, entity.version + 1)
    r.next = Entity(i)

proc storeToBin*(s: Stream; e: Entity) = storeToBin(s, EntityImpl(e))
proc initFromBin*(dst: var Entity; s: Stream) = initFromBin(EntityImpl(dst), s)

proc storeToBin*(s: Stream; r: Registry) =
  storeToBin(s, r.len)
  storeToBin(s, r.next)
  for i in 0 ..< r.len:
    storeToBin(s, r.data[i])

proc initFromBin*(dst: var Registry; s: Stream) =
  initFromBin(dst.len, s)
  initFromBin(dst.next, s)
  for i in 0 ..< dst.len:
    initFromBin(dst.data[i], s)
