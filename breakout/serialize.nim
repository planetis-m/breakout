import
  gametypes, slottables, vmath, heaparrays, std/streams,
  bingo, bingo/marshal_smartptrs, fusion/smartptrs
from typetraits import distinctBase

proc storeBin*[T: distinct](s: Stream; x: T) = storeBin(s, x.distinctBase)
proc initFromBin[T: distinct](dst: var T; s: Stream) = initFromBin(dst.distinctBase, s)

type
  SectionKind = enum
    secUnknown
    secSlotMap
    secSparseSet
    secSingleton
    secArray

  WrongSection = object of CatchableError

proc raiseWrongSection*(section, expected: SectionKind) {.noreturn.} =
  raise newException(WrongSection, "Got '" & $section & "', but expected '" & $expected & "'")

template storeSlotSection(data) =
  storeBin(s, secSlotMap)
  storeBin(s, data)

template storeSingleSection(data) =
  storeBin(s, secSingleton)
  storeBin(s, data)

template storeArrSection(component, data) =
  storeBin(s, secArray)
  var len = 0
  for _, signature in w.signature.pairs:
    if component in signature: inc(len)
  write(s, int64(len))
  for entity, signature in w.signature.pairs:
    if component in signature:
      write(s, entity.idx.EntityImpl)
      storeBin(s, data[entity.idx])

proc storeBin*(s: Stream; w: World) =
  storeSlotSection w.signature
  storeArrSection HasCollide, w.collide
  storeArrSection HasDraw2d, w.draw2d
  storeArrSection HasFade, w.fade
  storeArrSection HasHierarchy, w.hierarchy
  storeArrSection HasMove, w.move
  storeArrSection HasPrevious, w.previous
  storeSingleSection w.shake
  storeArrSection HasTransform2d, w.transform

proc initFromBin*[T](dst: var Array[T]; s: Stream) =
  let len = readInt64(s)
  dst.clear()
  for i in 0 ..< len:
    var idx: EntityImpl
    read(s, idx)
    initFromBin(dst[idx], s)

proc loadSeperator*(s: Stream, expected: SectionKind) =
  let section = binTo(s, SectionKind)
  if section != expected:
    raiseWrongSection(section, expected)

template loadArrSection(dst) =
  loadSeperator(s, secArray)
  loadBin(s, dst)

template loadSlotSection(dst) =
  loadSeperator(s, secSlotMap)
  loadBin(s, dst)

template loadSingleSection(dst) =
  loadSeperator(s, secSingleton)
  loadBin(s, dst)

proc initFromBin*(dst: var World; s: Stream) =
  loadSlotSection dst.signature
  loadArrSection dst.collide
  loadArrSection dst.draw2d
  loadArrSection dst.fade
  loadArrSection dst.hierarchy
  loadArrSection dst.move
  loadArrSection dst.previous
  loadSingleSection dst.shake
  loadArrSection dst.transform
