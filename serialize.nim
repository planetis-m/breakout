import
  game_types, registry, storage, sdl_private, vmath,
  std/[parsejson, streams], eminim, eminim/jsmartptrs, fusion/smartptrs
from typetraits import distinctBase

proc storeJson*[T: distinct](s: Stream; x: T) = storeJson(s, x.distinctBase)
proc initFromJson[T: distinct](dst: var T; p: var JsonParser) =
  initFromJson(dst.distinctBase, p)
# Remove once .skipped custom pragma is implemented
proc storeJson*(s: Stream; o: Window) = discard
proc storeJson*(s: Stream; o: Renderer) = discard
proc storeJson*(s: Stream; o: SdlContext) = discard
proc initFromJson*(dst: var Window; p: var JsonParser) = discard
proc initFromJson*(dst: var Renderer; p: var JsonParser) = discard
proc initFromJson*(dst: var SdlContext; p: var JsonParser) = discard

proc storeJson*[T](s: Stream; a: Storage[T]) =
   s.write "["
   var comma = false
   for e, v in a.pairs:
      if comma: s.write ","
      else: comma = true
      s.write "["
      storeJson(s, e)
      s.write ","
      storeJson(s, v)
      s.write "]"
   s.write "]"

proc initFromJson*[T](dst: var Storage[T]; p: var JsonParser) =
   eat(p, tkBracketLe)
   while p.tok != tkBracketRi:
      eat(p, tkBracketLe)
      var e: Entity
      initFromJson(e, p)
      eat(p, tkComma)
      var v: T
      initFromJson(v, p)
      dst[e] = v
      eat(p, tkBracketRi)
      if p.tok != tkComma: break
      discard getTok(p)
   eat(p, tkBracketRi)

type
   SomeComponent = Collide|Draw2d|Fade|Hierarchy|Move|Previous|Transform2d

proc storeJson*(s: Stream; g: Game) =
   const components = [HasCollide, HasDraw2d, HasFade, HasHierarchy,
                       HasMove, HasPrevious, HasTransform2d]
   var i = 0
   var comma = false
   s.write "{"
   for k, v in g.fieldPairs:
      if comma: s.write ","
      else: comma = true
      escapeJson(s, k)
      s.write ":"
      when v is seq[SomeComponent]:
         comma = false
         s.write "["
         for entity, has in g.world.pairs:
            if components[i] in has:
               if comma: s.write ","
               else: comma = true
               s.write "["
               storeJson(s, entity.index)
               s.write ","
               storeJson(s, v[entity.index])
               s.write "]"
         s.write "]"
         inc(i)
      else:
         storeJson(s, v)
   s.write "}"

proc initFromJson*[T: SomeComponent](dst: var seq[T]; p: var JsonParser) =
   dst = newSeq[T](maxEntities)
   eat(p, tkBracketLe)
   while p.tok != tkBracketRi:
      eat(p, tkBracketLe)
      var i = 0
      initFromJson(i, p)
      eat(p, tkComma)
      var val: T
      initFromJson(val, p)
      dst[i] = val
      eat(p, tkBracketRi)
      if p.tok != tkComma: break
      discard getTok(p)
   eat(p, tkBracketRi)

proc save*(game: Game) =
   let fs = newFileStream("save1.json", fmWrite)
   if fs != nil:
      storeJson(fs, game)
      fs.close()

proc load*(game: var Game) =
   let fs = newFileStream("save1.json")
   if fs != nil:
      loadJson(fs, game)
      fs.close()
