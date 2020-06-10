type
   EntityImpl = uint16
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
      entities: array[maxEntities, Entity]
      next: Entity

proc `==`*(a, b: Entity): bool {.borrow.}
proc toEntity(index, v: EntityImpl): Entity =
   result = Entity(v shl indexBits or index)
proc index*(self: Entity): EntityImpl =
   result = self.EntityImpl and indexMask
proc version*(self: Entity): EntityImpl =
   result = self.EntityImpl shr indexBits and versionMask

proc initRegistry*(): Registry =
   result = Registry(next: invalidId)

proc isValid*(r: Registry; entity: Entity): bool =
   ## Checks if an entity identifier refers to a valid entity.
   let i = entity.index
   result = i.int < r.len and r.entities[i] == entity

proc createEntity*(r: var Registry): Entity =
   ## Creates a new entity and returns it.
   ## There are two kinds of possible entity identifiers:
   ##
   ## Newly created ones in case no entities have been previously destroyed.
   ## Recycled ones with updated versions.
   if r.next == invalidId:
      assert r.len < maxEntities, "No more entities available!"
      result = Entity(r.len)
      r.entities[r.len] = result
      r.len.inc
   else:
      let i = r.next.EntityImpl
      let version = r.entities[i].version
      r.next = Entity(r.entities[i].index)
      result = toEntity(i, version)
      r.entities[i] = result

proc delete*(r: var Registry; entity: Entity) =
   ## When an entity is destroyed, its version is updated and the identifier
   ## can be recycled at any time.
   # lengthens the implicit list of next entities
   let i = entity.index
   r.entities[i] = toEntity(r.next.EntityImpl, entity.version + 1)
   r.next = Entity(i)
