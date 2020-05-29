import game_types, algorithm

type
   SparseSet*[T] = object
      len*: int
      sparse*: array[MaxEntities, uint16] # mapping from sparse handles to dense values
      dense*: seq[T]

proc initSparseSet*[T](denseCap: Natural): SparseSet[T] =
   # `denseCap` how many components.
   result = SparseSet[T](dense: newSeq[T](denseCap))
   result.sparse.fill(invalidId)

proc clear*[T](x: var SparseSet[T]) =
   x.len = 0

proc contains*[T](x: SparseSet[T], entity: Entity): bool =
   # Returns true if the sparse is registered to a dense index.
   result = x.sparse[entity] != invalidId

proc `[]=`*[T](x: var SparseSet[T], entity: Entity, value: T) {.nodestroy.} =
   var dense: Entity
   if entity in x:
      dense = x.sparse[entity]
   else:
      dense = uint16(x.len)
      x.sparse[entity] = dense
      inc(x.len)
   x.dense[dense] = value

proc `[]`*[T](x: SparseSet[T], entity: Entity): T =
   assert(x.len > 0)
   assert(x.contains(entity))
   let dense = x.sparse[entity]
   result = x.dense[dense]

proc `[]`*[T](x: var SparseSet[T], entity: Entity): var T =
   assert(x.len > 0)
   assert(x.contains(entity))
   let dense = x.sparse[entity]
   result = x.dense[dense]

# proc del*(x: var SparseSet[T], entity: Entity) =
#    assert(x.len > 0)
#    assert(x.contains(entity))
#    let dense = x.sparse[entity]
#    x.sparse[x.lastSparse] = dense
#    x.dense.del(entity)

when isMainModule:
   var ss = initSparseSet[Entity](128)

   let ent1 = Entity(1)
   let ent2 = Entity(2)
   ss[ent1] = Entity(0)
   ss[ent2] = Entity(4)
   assert(ss.len() == 2)
   ss.clear()

   ss[ent1] = Entity(10)
   assert ss[ent1] == 10
