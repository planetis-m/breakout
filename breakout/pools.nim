type
  Pool*[T, I] = object
    items: seq[T]
    freeList: seq[int32]

proc alloc*[T, I](pool: var Pool[T, I]; value: sink T): I {.inline.} =
  if pool.freeList.len > 0:
    result = I(pool.freeList.pop())
    pool.items[result.int] = value
  else:
    result = I(pool.items.len.int32)
    pool.items.add(value)

proc free*[T, I](pool: var Pool[T, I]; idx: I) {.inline.} =
  pool.items[idx.int] = default(T)
  pool.freeList.add(idx.int32)

proc `[]`*[T, I](pool: Pool[T, I]; idx: I): lent T {.inline.} =
  pool.items[idx.int]

proc `[]`*[T, I](pool: var Pool[T, I]; idx: I): var T {.inline.} =
  pool.items[idx.int]
