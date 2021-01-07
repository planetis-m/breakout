import
  gametypes, slottables, vmath, heaparrays, std/streams,
  bingo, bingo/marshal_smartptrs, fusion/smartptrs
from typetraits import distinctBase

proc storeBin*[T: distinct](s: Stream; x: T) = storeBin(s, x.distinctBase)
proc initFromBin[T: distinct](dst: var T; s: Stream) = initFromBin(dst.distinctBase, s)

proc storeBin*(s: Stream; w: World) =
  const components = [HasCollide, HasDraw2d, HasFade, HasHierarchy,
                      HasMove, HasPrevious, HasTransform2d]
  var i = 0
  for v in w.fields:
    when v is Array:
      var len = 0
      for _, signature in w.signature.pairs:
        if components[i] in signature: inc(len)
      write(s, int64(len))
      for entity, signature in w.signature.pairs:
        if components[i] in signature:
          write(s, entity.idx.EntityImpl)
          storeBin(s, v[entity.idx])
      inc(i)
    else:
      storeBin(s, v)

proc initFromBin*[T](dst: var Array[T]; s: Stream) =
  let len = readInt64(s)
  dst.clear()
  for i in 0 ..< len:
    var idx: EntityImpl
    read(s, idx)
    initFromBin(dst[idx], s)
