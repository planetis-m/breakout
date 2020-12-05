import
  game_types, registry, storage, sdl_private, vmath,
  std/streams, bingod, bingod/marshal_smartptrs, fusion/smartptrs
from typetraits import distinctBase

proc storeToBin*[T: distinct](s: Stream; x: T) = storeToBin(s, x.distinctBase)
proc initFromBin[T: distinct](dst: var T; s: Stream) =
  initFromBin(dst.distinctBase, s)
# Remove once .skipped custom pragma is implemented
proc storeToBin*(s: Stream; o: Window) = discard
proc storeToBin*(s: Stream; o: Renderer) = discard
proc storeToBin*(s: Stream; o: SdlContext) = discard
proc initFromBin*(dst: var Window; s: Stream) = discard
proc initFromBin*(dst: var Renderer; s: Stream) = discard
proc initFromBin*(dst: var SdlContext; s: Stream) = discard

proc storeToBin*[T](s: Stream; a: Storage[T]) =
   write(s, int64(a.len))
   for e, v in a.pairs:
      storeToBin(s, e)
      storeToBin(s, v)

proc initFromBin*[T](dst: var Storage[T]; s: Stream) =
   let len = s.readInt64()
   for i in 0 ..< len:
      var e: Entity
      initFromBin(e, s)
      initFromBin(dst[e], s)

type
   SomeComponent = Collide|Draw2d|Fade|Hierarchy|Move|Previous|Transform2d

proc storeToBin*(s: Stream; g: Game) =
   const components = [HasCollide, HasDraw2d, HasFade, HasHierarchy,
                       HasMove, HasPrevious, HasTransform2d]
   var i = 0
   for v in g.fields:
      when v is seq[SomeComponent]:
         var len = 0
         for _, has in g.world.pairs:
            if components[i] in has: inc(len)
         storeToBin(s, int64(len))
         for entity, has in g.world.pairs:
            if components[i] in has:
               storeToBin(s, entity.index)
               storeToBin(s, v[entity.index])
         inc(i)
      else:
         storeToBin(s, v)

proc initFromBin*[T: SomeComponent](dst: var seq[T]; s: Stream) =
   dst = newSeq[T](maxEntities)
   let len = readInt64(s)
   for i in 0 ..< len:
      var j = 0
      initFromBin(j, s)
      initFromBin(dst[j], s)

proc save*(game: Game) =
   let fs = newFileStream("save1.bin", fmWrite)
   if fs != nil:
      storeBin(fs, game)
      fs.close()

proc load*(game: var Game) =
   let fs = newFileStream("save1.bin")
   if fs != nil:
      loadBin(fs, game)
      fs.close()
