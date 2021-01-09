import
  gametypes, slottables, vmath, heaparrays, std/streams,
  bingo, bingo/marshal_smartptrs, fusion/smartptrs
from typetraits import distinctBase

proc storeBin*[T: distinct](s: Stream; x: T) = storeBin(s, x.distinctBase)
proc initFromBin[T: distinct](dst: var T; s: Stream) = initFromBin(dst.distinctBase, s)

type
  WrongSection = object of CatchableError

proc raiseWrongSection*(component, expected: HasComponent) {.noreturn.} =
  raise newException(WrongSection, "Got '" & $component & "', but expected '" & $expected & "'")

template storeSection(component, data) =
  storeBin(s, component)
  var len = 0
  for _, signature in w.signature.pairs:
    if component in signature: inc(len)
  write(s, int64(len))
  for entity, signature in w.signature.pairs:
    if component in signature:
      write(s, entity.idx.EntityImpl)
      storeBin(s, data[entity.idx])

proc storeBin*(s: Stream; w: World) =
  #storeBin(s, int16(len(HasComponent)))
  storeBin(s, w.signature)
  storeSection HasCollide, w.collide
  storeSection HasDraw2d, w.draw2d
  storeSection HasFade, w.fade
  storeSection HasHierarchy, w.hierarchy
  storeSection HasMove, w.move
  storeSection HasPrevious, w.previous
  storeBin(s, HasShake)
  storeBin(s, w.shake)
  storeSection HasTransform2d, w.transform

proc initFromBin*[T](dst: var Array[T]; s: Stream) =
  let len = readInt64(s)
  dst.clear()
  for i in 0 ..< len:
    var idx: EntityImpl
    read(s, idx)
    initFromBin(dst[idx], s)

proc loadSeperator*(s: Stream, expected: HasComponent) =
  let component = binTo(s, HasComponent)
  if component != expected:
    raiseWrongSection(component, expected)

template loadSection(component, data) =
  loadSeperator(s, component)
  loadBin(s, data)

proc initFromBin*(dst: var World; s: Stream) =
  var currentSection: HasComponent
  loadBin(s, dst.signature)
  loadSection HasCollide, dst.collide
  loadSection HasDraw2d, dst.draw2d
  loadSection HasFade, dst.fade
  loadSection HasHierarchy, dst.hierarchy
  loadSection HasMove, dst.move
  loadSection HasPrevious, dst.previous
  loadSeperator(s, HasShake)
  loadBin(s, dst.shake)
  loadSection HasTransform2d, dst.transform
