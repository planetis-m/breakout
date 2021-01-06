import entities, heaparrays, bingo, std/streams

type
  Entry*[T] = tuple
    e: Entity
    value: T
  SlotTable*[T] = object
    freeHead: int
    slots: seq[Entity]
    data: seq[Entry[T]]

proc initSlotTableOfCap*[T](capacity: Natural): SlotTable[T] =
  result = SlotTable[T](
    data: newSeqOfCap[Entry[T]](capacity),
    slots: newSeqOfCap[Entity](capacity),
    freeHead: 0
  )

proc len*[T](x: SlotTable[T]): int {.inline.} =
  result = x.data.len

proc contains*[T](x: SlotTable[T], e: Entity): bool =
  result = e.idx < x.slots.len and
      x.slots[e.idx].version == e.version

proc incl*[T](x: var SlotTable[T], value: T): Entity =
  if x.len + 1 == maxEntities:
    raise newException(RangeDefect, "SlotTable number of elements overflow")
  let idx = x.freeHead
  if idx < x.slots.len:
    template slot: untyped = x.slots[idx]
    let occupiedVersion = slot.version or 1
    result = toEntity(idx.EntityImpl, occupiedVersion)
    x.data.add((e: result, value: value))
    x.freeHead = slot.idx
    slot = toEntity(x.data.high.EntityImpl, occupiedVersion)
  else:
    result = toEntity(idx.EntityImpl, 1)
    x.data.add((e: result, value: value))
    x.slots.add(toEntity(x.data.high.EntityImpl, 1))
    x.freeHead = x.slots.len

proc freeSlot[T](x: var SlotTable[T], slotIdx: int): int {.inline.} =
  # Helper function to add a slot to the freelist. Returns the index that
  # was stored in the slot.
  template slot: untyped = x.slots[slotIdx]
  result = slot.idx
  slot = toEntity(x.freeHead.EntityImpl, slot.version + 1)
  x.freeHead = slotIdx

proc delFromSlot[T](x: var SlotTable[T], slotIdx: int) {.inline.} =
  # Helper function to remove a value from a slot and make the slot free.
  # Returns the value deld.
  let valueIdx = x.freeSlot(slotIdx)
  # Remove values/slot_indices by swapping to end.
  x.data[valueIdx] = move(x.data[x.data.high])
  x.data.shrink(x.data.high)
  # Did something take our place? Update its slot to new position.
  if x.data.len > valueIdx:
    let kIdx = x.data[valueIdx].e.idx
    template slot: untyped = x.slots[kIdx]
    slot = toEntity(valueIdx.EntityImpl, slot.version)

proc del*[T](x: var SlotTable[T], e: Entity) =
  if x.contains(e):
    x.delFromSlot(e.idx)

proc clear*[T](x: var SlotTable[T]) =
  x.freeHead = 0
  x.slots.shrink(0)
  x.data.shrink(0)

template get(x, e) =
  template slot: untyped = x.slots[e.idx]
  if e.idx >= x.slots.len or slot.version != e.version:
    raise newException(KeyError, "Entity not in SlotTable")
  # This is safe because we only store valid indices.
  let idx = slot.idx
  result = x.data[idx].value

proc `[]`*[T](x: SlotTable[T], e: Entity): T =
  get(x, e)

proc `[]`*[T](x: var SlotTable[T], e: Entity): var T =
  get(x, e)

iterator pairs*[T](x: SlotTable[T]): Entry[T] =
  for i in 0 ..< x.len:
    yield x.data[i]

# Serialization
proc storeBin*[T](s: Stream; a: SlotTable[T]) =
  write(s, int64(a.slots.len))
  for x in a.slots:
    write(s, x.version)
    if x.version mod 2 > 0:
      storeToBin(s, a.data[x.idx].value)

proc initFromBin*[T](dst: var SlotTable[T]; s: Stream) =
  let len = s.readInt64()
  dst.clear()
  var nextFree = len.int
  for i in 0 ..< len:
    var version: EntityImpl
    read(s, version)
    if version mod 2 > 0:
      let value = binTo(s, T)
      dst.data.add((e: toEntity(i.EntityImpl, version), value: value))
      dst.slots.add(toEntity(dst.data.high.EntityImpl, version))
    else:
      dst.slots.add(toEntity(nextFree.EntityImpl, version))
      nextFree = i.int
  dst.freeHead = nextFree
