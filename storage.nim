
type
   Storage = object
      sparseToPacked: seq[ArrayIndex]
      packedToSparse: seq[Entity]
      packed: seq[Component]

proc assign*[T](s: Storage[T], entity: Entity, component: T): T =
   assure(s, entity)
   let entityIndex = entity.index

   let packedIndex = s.sparseToPacked[entityIndex]
   if packedIndex == invalidId:
      packedIndex = s.packed.len
      s.packedToSparse.add(entity)
      s.packed.add(component)
      s.sparseToPacked[entityIndex] = packedIndex
   else:
      s.packed[packedIndex] = component

   result = s.packed[packedIndex]

proc remove*[T](s: Storage[T], entity: Entity) =
   let entityIndex = entity.index
   if entity.index < s.sparseToPacked.len:
      return

   let packedIndex = s.sparseToPacked[entityIndex]
   if packedIndex == invalidId:
      return

   let lastIndex = s.packed.high
   let lastEntity = s.packedToSparse[lastIndex]
   s.sparseToPacked[entityIndex] = invalidId
   s.sparseToPacked[lastEntity.index] = packedIndex
   swap(s.packed[packedIndex], s.packed[lastIndex])
   discard s.packed.pop()
   swap(s.packedToSparse[packedIndex], s.packedToSparse[lastIndex])
   discard s.packedToSparse.pop()

proc assure*(s: Storage[T], entity: Entity) =
   let entityIndex = entity.index
   if s.sparseToPacked.len <= entityIndex:
      s.sparseToPacked.grow(entityIndex + 1, invalidId)

proc `[]`*[T](s: Storage[T], entity: Entity): T =
   if s.contains(entity):
      let entityIndex = entity.index
      result = s.packed[s.sparseToPacked[entityIndex]]

proc contains*[T](s: Storage[T], entity: Entity): bool =
   let entityIndex = entity.index
   result = entityIndex < s.sparseToPacked.len and
         s.sparseToPacked[entityIndex] != invalidId

proc len*[T](s: Storage[T]): int =
   result = s.packed.len

proc clean*[T](s: Storage[T]) =
   s.packed.shrink(0)
   s.packedToSparse.shrink(0)
   s.sparseToPacked.shrink(0)
