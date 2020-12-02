import eminim, std/[streams, parsejson]

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
proc index*(self: Entity): EntityImpl =
   result = self.EntityImpl and indexMask
proc version*(self: Entity): EntityImpl =
   result = self.EntityImpl shr indexBits and versionMask

proc initRegistry*(): Registry =
   result = Registry(next: invalidId)

proc isValid*(r: Registry; entity: Entity): bool =
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

proc storeJson*(s: Stream; e: Entity) = storeJson(s, int(e))
proc storeJson*(s: Stream; e: EntityImpl) = storeJson(s, int(e))
proc initFromJson*(dst: var Entity; p: var JsonParser) = initFromJson(EntityImpl(dst), p)
proc initFromJson*(dst: var EntityImpl; p: var JsonParser) = initFromJson(dst, p)

proc storeJson*(s: Stream; r: Registry) =
   s.write "{"
   escapeJson(s, "len")
   s.write ":"
   storeJson(s, r.len)
   s.write ","
   escapeJson(s, "next")
   s.write ":"
   storeJson(s, r.next)
   s.write ","
   escapeJson(s, "data")
   s.write ":"
   var comma = false
   s.write "["
   for i in 0 ..< r.len:
      if comma: s.write ","
      else: comma = true
      storeJson(s, r.data[i])
   s.write "]"
   s.write "}"
