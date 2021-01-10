import
  gametypes, slottables, vmath, heaparrays, std/streams,
  bingo, bingo/marshal_smartptrs, fusion/smartptrs
from typetraits import distinctBase

proc storeBin*[T: distinct](s: Stream; x: T) = storeBin(s, x.distinctBase)
proc initFromBin[T: distinct](dst: var T; s: Stream) = initFromBin(dst.distinctBase, s)

type
  WrongSection = object of CatchableError
  GameSection* = enum
    secSignature = -1
    secCollide = HasCollide
    secDraw2d = HasDraw2d
    secFade = HasFade
    secHierarchy = HasHierarchy
    secMove = HasMove
    secPrevious = HasPrevious
    secShake = HasShake
    secTransform2d = HasTransform2d

proc raiseWrongSection*(section, expected: GameSection) {.noreturn.} =
  raise newException(WrongSection, "Got '" & $section & "', but expected '" & $expected & "'")

template storeSection(section, data) =
  storeBin(s, section)
  var len = 0
  for _, signature in w.signature.pairs:
    if section.HasComponent in signature: inc(len)
  write(s, int64(len))
  for entity, signature in w.signature.pairs:
    if section.HasComponent in signature:
      write(s, entity.idx.EntityImpl)
      storeBin(s, data[entity.idx])

proc storeBin*(s: Stream; w: World) =
  storeBin(s, secSignature)
  storeBin(s, w.signature)
  storeSection secCollide, w.collide
  storeSection secDraw2d, w.draw2d
  storeSection secFade, w.fade
  storeSection secHierarchy, w.hierarchy
  storeSection secMove, w.move
  storeSection secPrevious, w.previous
  storeBin(s, secShake)
  storeBin(s, w.shake)
  storeSection secTransform2d, w.transform

proc initFromBin*[T](dst: var Array[T]; s: Stream) =
  let len = readInt64(s)
  dst.clear()
  for i in 0 ..< len:
    var idx: EntityImpl
    read(s, idx)
    initFromBin(dst[idx], s)

proc loadSeperator*(s: Stream, expected: GameSection) =
  let section = binTo(s, GameSection)
  if section != expected:
    raiseWrongSection(section, expected)

template loadSection(section, data) =
  loadSeperator(s, section)
  loadBin(s, data)

proc initFromBin*(dst: var World; s: Stream) =
  var currentSection: GameSection
  loadSeperator(s, secSignature)
  loadBin(s, dst.signature)
  loadSection secCollide, dst.collide
  loadSection secDraw2d, dst.draw2d
  loadSection secFade, dst.fade
  loadSection secHierarchy, dst.hierarchy
  loadSection secMove, dst.move
  loadSection secPrevious, dst.previous
  loadSeperator(s, secShake)
  loadBin(s, dst.shake)
  loadSection secTransform2d, dst.transform
