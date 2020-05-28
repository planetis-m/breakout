import game_types, algorithm

proc initSparseSet*[T](denseCap: Natural): SparseSet[T] =
   # `denseCap` how many components.
   result = SparseSet[T](dense: newSeqOfCap[T](denseCap))
   result.sparse.fill(invalidId)

proc clear*[T](x: var SparseSet[T]) =
   x.dense.shrink(0)

proc len*[T](x: SparseSet[T]): int {.inline.} =
   # Returns the amount of allocated handles.
   result = x.dense.len

proc `[]=`*(x: var SparseSet[T], entity: Entity, value: T) {.nodestroy.} =
   x.sparse[entity] = x.len
   x.dense.add(value)

proc `[]`*(x: var SparseSet[T], entity: Entity): T =
   let dense = x.sparse[entity]
   result = x.dense[dense]

proc contains*[T](x: SparseSet[T], entity: Entity): bool =
   # Returns true if the sparse is registered to a dense index.
   result = x.sparse[entity] != invalidId

# proc del*(x: var SparseSet[T], entity: Entity) =
#    assert(self.len > 0)
#    assert(self.contains(entity))
#    let dense = self.sparse[entity]
#    self.sparse[self.lastSparse] = dense
#    self.dense.del(entity)

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
