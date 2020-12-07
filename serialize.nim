import
   gametypes, registry, storage, sdlpriv, vmath, heaparray,
   std/streams, bingod, bingod/marshal_smartptrs, fusion/smartptrs
from typetraits import distinctBase

proc storeToBin*[T: distinct](s: Stream; x: T) = storeToBin(s, x.distinctBase)
proc initFromBin[T: distinct](dst: var T; s: Stream) = initFromBin(dst.distinctBase, s)

proc storeToBin*[T](s: Stream; a: Storage[T]) =
   write(s, int64(a.len))
   for e, v in a.pairs:
      storeToBin(s, e)
      storeToBin(s, v)

proc initFromBin*[T](dst: var Storage[T]; s: Stream) =
   let len = s.readInt64()
   dst = initStorage[T]()
   for i in 0 ..< len:
      var e: Entity
      initFromBin(e, s)
      var v: T
      initFromBin(v, s)
      dst[e] = v

proc storeToBin*(s: Stream; w: World) =
   const components = [HasCollide, HasDraw2d, HasFade, HasHierarchy,
                       HasMove, HasPrevious, HasTransform2d]
   var i = 0
   for v in w.fields:
      when v is Array:
         var len = 0
         for _, has in w.signature.pairs:
            if components[i] in has: inc(len)
         storeToBin(s, int64(len))
         for entity, has in w.signature.pairs:
            if components[i] in has:
               storeToBin(s, entity.index)
               storeToBin(s, v[entity.index])
         inc(i)
      else:
         storeToBin(s, v)

proc initFromBin*[T](dst: var Array[T]; s: Stream) =
   dst = initArray[T]()
   let len = readInt64(s)
   for i in 0 ..< len:
      var j: EntityImpl
      initFromBin(j, s)
      initFromBin(dst[j], s)

proc save*(game: Game) =
   let fs = newFileStream("save1.bin", fmWrite)
   if fs != nil:
      try: storeBin(fs, game.world) finally: fs.close()

proc load*(game: var Game) =
   let fs = newFileStream("save1.bin")
   if fs != nil:
      try: loadBin(fs, game.world) finally: fs.close()
