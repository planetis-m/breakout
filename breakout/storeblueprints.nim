from typetraits import distinctBase

proc storeJson*(s: Stream; x: Entity) = storeJson(s, x.int)
proc storeJson*(s: Stream; x: uint16) = storeJson(s, x.int)
proc storeJson*[T: distinct](s: Stream; x: T) = storeJson(s, x.distinctBase)

proc storeJson*(s: Stream; world: World; entity: Entity) =
  const components = [HasCollide, HasDraw2d, HasFade, HasHierarchy,
                      HasMove, HasPrevious, HasShake, HasTransform2d]
  var comma = false
  let signature = world.signature[entity]
  s.write "{"
  if HasHierarchy in signature:
    template hierarchy: untyped = world.hierarchy[entity.idx]
    escapeJson(s, "hierarchy")
    s.write ":["
    var childId = hierarchy.head
    while childId != invalidId:
      template childHierarchy: untyped = world.hierarchy[childId.idx]
      if comma: s.write ","
      else: comma = true
      storeJson(s, world, childId)
      childId = childHierarchy.next
    s.write "],"
  escapeJson(s, "with")
  s.write ":["
  comma = false
  for x in signature:
    if comma: s.write ","
    else: comma = true
    s.write "["
    storeJson(s, x)
    case x
    of HasCollide:
      s.write ","
      storeJson(s, world.collide[entity.idx])
    of HasDraw2d:
      s.write ","
      storeJson(s, world.draw2d[entity.idx])
    of HasFade:
      s.write ","
      storeJson(s, world.fade[entity.idx])
    of HasMove:
      s.write ","
      storeJson(s, world.move[entity.idx])
    of HasShake:
      s.write ","
      storeJson(s, world.shake[])
    of HasTransform2d:
      s.write ","
      storeJson(s, world.transform[entity.idx])
    else: discard
    s.write "]"

  #comma = false
  #for x in signature:
    #if comma: s.write ","
    #else: comma = true
    #s.write "["
    #storeJson(s, x)
    #var i = 0
    #for f in world.fields:
      #when f is Array:
        #if components[i] == x:
          #s.write ","
          #storeJson(s, f[entity.idx])
        #inc(i)
      #elif f is UniquePtr:
        #if components[i] == x:
          #s.write ","
          #storeJson(s, f)
        #inc(i)
    #s.write "]"
  s.write "}"

proc saveScene*(game: Game; savefile: string) =
  let fs = newFileStream(savefile, fmWrite)
  if fs != nil:
    try:
      storeJson(fs, game.world, game.camera)
    finally:
      fs.close()
