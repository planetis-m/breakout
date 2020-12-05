import registry, std / algorithm

type
   Storage*[T] = object
      len: int
      sparseToPacked: array[maxEntities, EntityImpl] # mapping from sparse handles to dense values
      packedToSparse: array[maxEntities, Entity] # mapping from dense values to sparse handles
      packed: seq[T]

proc initStorage*[T](denseCap: Natural): Storage[T] =
   result = Storage[T](packed: newSeq[T](denseCap))
   result.sparseToPacked.fill(invalidId.EntityImpl)
   result.packedToSparse.fill(invalidId)

proc contains*[T](s: Storage[T], entity: Entity): bool =
   # Returns true if the sparse is registered to a dense index.
   s.sparseToPacked[entity.index] != invalidId.EntityImpl

proc `[]=`*[T](s: var Storage[T], entity: Entity, value: sink T) =
   ## Inserts a `(entity, value)` pair into `s`.
   let entityIndex = entity.index
   var packedIndex = s.sparseToPacked[entityIndex]
   if packedIndex == invalidId.EntityImpl:
      packedIndex = s.len.EntityImpl
      s.packedToSparse[packedIndex] = entity
      s.sparseToPacked[entityIndex] = packedIndex
      s.len.inc
   s.packed[packedIndex] = value

template get(s, entity) =
   let entityIndex = entity.index
   let packedIndex = s.sparseToPacked[entityIndex]
   if packedIndex == invalidId.EntityImpl:
      echo entityIndex
      raise newException(KeyError, "Entity not in Storage")
   result = s.packed[packedIndex]

proc `[]`*[T](s: var Storage[T], entity: Entity): var T =
   ## Retrieves the value at `s[entity]`. The value can be modified.
   ## If `entity` is not in `s`, the `KeyError` exception is raised.
   get(s, entity)
proc `[]`*[T](s: Storage[T], entity: Entity): lent T =
   ## Retrieves the value at `s[entity]`.
   ## If `entity` is not in `s`, the `KeyError` exception is raised.
   get(s, entity)

proc delete*[T](s: var Storage[T], entity: Entity) =
   ## Deletes `entity` from sparse set `s`. Does nothing if the key does not exist.
   let entityIndex = entity.index
   let packedIndex = s.sparseToPacked[entityIndex]
   if packedIndex != invalidId.EntityImpl:
      let lastIndex = s.len - 1
      let lastEntity = s.packedToSparse[lastIndex]
      s.sparseToPacked[lastEntity.index] = packedIndex
      s.sparseToPacked[entityIndex] = invalidId.EntityImpl
      s.packed[packedIndex] = move(s.packed[lastIndex])
      s.packed[lastIndex] = default(T)
      s.packedToSparse[packedIndex] = s.packedToSparse[lastIndex]
      s.packedToSparse[lastIndex] = invalidId
      s.len.dec

proc clear*[T](s: var Storage[T]) =
   s.sparseToPacked.fill(invalidId.EntityImpl)
   s.packedToSparse.fill(invalidId)
   s.len = 0

proc len*[T](s: Storage[T]): int = s.len

iterator pairs*[T](s: Storage[T]): (Entity, lent T) =
   for i in 0 ..< s.len:
      yield (s.packedToSparse[i], s.packed[i])
