import
  gametypes, slotmap, vmath, heaparray, std/streams,
  bingo, bingo/marshal_smartptrs, fusion/smartptrs
from typetraits import distinctBase

proc storeToBin*[T: distinct](s: Stream; x: T) = storeToBin(s, x.distinctBase)
proc initFromBin[T: distinct](dst: var T; s: Stream) = initFromBin(dst.distinctBase, s)

proc storeToBin*(s: Stream; w: World) =
  const components = [HasCollide, HasDraw2d, HasFade, HasHierarchy,
                      HasMove, HasPrevious, HasTransform2d]
  var i = 0
  for v in w.fields:
    when v is Array:
      var len = 0
      for _, has in w.signature.pairs:
        if components[i] in has: inc(len)
      write(s, int64(len))
      for entity, has in w.signature.pairs:
        if components[i] in has:
          write(s, entity.idx.uint16)
          storeToBin(s, v[entity.idx])
      inc(i)
    else:
      storeToBin(s, v)

proc initFromBin*[T](dst: var Array[T]; s: Stream) =
  let len = readInt64(s)
  dst.clear()
  for i in 0 ..< len:
    let idx = readUint16(s)
    initFromBin(dst[idx], s)

proc save*(game: Game) =
  let fs = newFileStream("save1.bin", fmWrite)
  if fs != nil:
    try: storeBin(fs, game.world) finally: fs.close()

proc load*(game: var Game) =
  let fs = newFileStream("save1.bin")
  if fs != nil:
    try: loadBin(fs, game.world) finally: fs.close()
