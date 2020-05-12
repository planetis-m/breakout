type
   Vec2* = object
      x*: float32
      y*: float32

   Mat2d* = object
      m00*: float32
      m01*: float32
      m02*: float32
      m10*: float32
      m11*: float32
      m12*: float32

   HasComponent* = enum
      HasDraw2d,
      HasFade,
      HasMove,
      HasShake,
      HasTransform2d,

   Draw2d* = object
      width*, height*: int32
      color*: array[4, uint8]

   Fade* = object
      step*: float32

   Move* = object
      direction*: Vec2
      speed*: float32

   Shake* = object
      duration*: float32
      strength*: float32

   Transform2d* = object
      world*: Mat2d      # Matrix relative to the world
      self*: Mat2d       # World to self matrix
      translation*: Vec2 # local translation relative to the parent
      rotation*: float32 # local rotation relative to the parent
      scale*: Vec2       # local scale relative to the parent

   Archetype = object
      kind: set[HasComponent]
      len: int

      draw2d*: ptr UncheckedArray[Draw2d]
      fade*: ptr UncheckedArray[Fade]
      move*: ptr UncheckedArray[Move]
      shake*: ptr UncheckedArray[Shake]
      transform*: ptr UncheckedArray[Transform2d]

      p: ptr ArchPayloadBase

   ArchPayloadBase = object
      cap: int

template `+!`(p: pointer, s: int): pointer =
   cast[pointer](cast[int](p) +% s)

proc align(address, alignment: int): int =
   result = (address + (alignment - 1)) and not (alignment - 1)

proc `=destroy`*(x: var Archetype) =
   if x.p != nil:
      for i in 0 ..< x.len:
         if HasDraw2d in x.kind: `=destroy`(x.draw2d[i])
         if HasFade in x.kind: `=destroy`(x.fade[i])
         if HasMove in x.kind: `=destroy`(x.move[i])
         if HasShake in x.kind: `=destroy`(x.shake[i])
         if HasTransform2d in x.kind: `=destroy`(x.transform[i])
      dealloc(x.p)
      x.p = nil

proc `=`*(a: var Archetype; b: Archetype) {.error.}

proc newArchPayload1(cap: int): ptr ArchPayloadBase =
   var p = cast[ptr ArchPayloadBase](allocShared0(
         align(sizeof(ArchPayloadBase), alignof(Shake)) +
         align(cap * sizeof(Shake), alignof(Transform2d)) +
         cap * sizeof(Transform2d)))
   p.cap = cap
   result = p

proc newArchPayload2(cap: int): ptr ArchPayloadBase =
   var p = cast[ptr ArchPayloadBase](allocShared0(
         align(sizeof(ArchPayloadBase), alignof(Draw2d)) +
         align(cap * sizeof(Draw2d), alignof(Fade)) +
         align(cap * sizeof(Fade), alignof(Move)) +
         align(cap * sizeof(Move), alignof(Shake)) +
         align(cap * sizeof(Shake), alignof(Transform2d)) +
         cap * sizeof(Transform2d)))
   p.cap = cap
   result = p

proc initArchetype1(cap: Natural): Archetype =
   result = Archetype(kind: {HasShake, HasTransform2d}, len: 0, p: newArchPayload1(cap))
   var pPtr = result.p +!
         align(sizeof(ArchPayloadBase), alignof(Shake))
   result.shake = cast[typeof(result.shake)](pPtr)
   pPtr = pPtr +! align(cap * sizeof(Shake), alignof(Transform2d))
   result.transform = cast[typeof(result.transform)](pPtr)

proc initArchetype2(cap: Natural): Archetype =
   result = Archetype(kind: {HasDraw2d, HasFade, HasMove, HasShake, HasTransform2d},
         len: 0, p: newArchPayload2(cap))
   var pPtr = result.p +!
         align(sizeof(ArchPayloadBase), alignof(Draw2d))
   result.draw2d = cast[typeof(result.draw2d)](pPtr)
   pPtr = pPtr +! align(cap * sizeof(Draw2d), alignof(Fade))
   result.fade = cast[typeof(result.fade)](pPtr)
   pPtr = pPtr +! align(cap * sizeof(Fade), alignof(Move))
   result.move = cast[typeof(result.move)](pPtr)
   pPtr = pPtr +! align(cap * sizeof(Move), alignof(Shake))
   result.shake = cast[typeof(result.shake)](pPtr)
   pPtr = pPtr +! align(cap * sizeof(Shake), alignof(Transform2d))
   result.transform = cast[typeof(result.transform)](pPtr)

proc del*(x: var Archetype, i: Natural) =
   let xl = x.len - 1
   if HasDraw2d in x.kind: x.draw2d[i] = move(x.draw2d[xl])
   if HasFade in x.kind: x.fade[i] = move(x.fade[xl])
   if HasMove in x.kind: x.move[i] = move(x.move[xl])
   if HasShake in x.kind: x.shake[i] = move(x.shake[xl])
   if HasTransform2d in x.kind: x.transform[i] = move(x.transform[xl])
   for i in countdown(x.len - 1, xl):
      if HasDraw2d in x.kind: `=destroy`(x.draw2d[i])
      if HasFade in x.kind: `=destroy`(x.fade[i])
      if HasMove in x.kind: `=destroy`(x.move[i])
      if HasShake in x.kind: `=destroy`(x.shake[i])
      if HasTransform2d in x.kind: `=destroy`(x.transform[i])
   x.len = xl

proc add*(x: var Archetype; value: (Shake, Transform2d)) {.nodestroy.} =
   assert x.kind == {HasShake, HasTransform2d}
   let oldLen = x.len
   if x.p.cap < oldLen + 1:
      raise newException(ResourceExhaustedError, "Reached max number of entities per archetype")
   x.len = oldLen + 1
   x.shake[oldLen] = value[0]
   x.transform[oldLen] = value[1]

proc add*(x: var Archetype; value: (Draw2d, Fade, Move, Shake, Transform2d)) {.nodestroy.} =
   assert x.kind == {HasDraw2d, HasFade, HasMove, HasShake, HasTransform2d}
   let oldLen = x.len
   if x.p.cap < oldLen + 1:
      raise newException(ResourceExhaustedError, "Reached max number of entities per archetype")
   x.len = oldLen + 1
   x.draw2d[oldLen] = value[0]
   x.fade[oldLen] = value[1]
   x.move[oldLen] = value[2]
   x.shake[oldLen] = value[3]
   x.transform[oldLen] = value[4]

import std / [times, monotimes]

proc main =
   var lastTime = getMonoTime()
   var archetypes = @[initArchetype1(1000), initArchetype2(2000)]

#    let camera =
#       for archetype in archetypes.mitems:
#          if archetype.kind == {HasShake, HasTransform2d}:
#
#    template cameraShake: untyped = archetypes[0].shake[camera]
#    cameraShake.strength = 20.0
   for i in 1 .. 2000:
      archetypes[1].add (
         Draw2d(width: 100, height: 20, color: [255'u8, 0, 0, 255]),
         Fade(step: 0.05),
         Move(speed: 600.0),
         Shake(duration: 0.0, strength: 20.0),
         Transform2d(translation: Vec2(x: i.float32, y: i.float32), scale: Vec2(x: 1.0, y: 1.0)))

   for i in 1 .. 1000:
      let now = getMonoTime()
      let delta = inMilliseconds(now - lastTime).float32 / 1000.0'f32
      for archetype in archetypes.mitems:
         if archetype.kind * {HasMove, HasTransform2d} == {}:
            for i in 0 ..< archetype.len:
               template transform: untyped = archetype.transform[i]
               template move: untyped = archetype.move[i]

               transform.translation.x += move.direction.x * move.speed * delta
               transform.translation.y += move.direction.y * move.speed * delta
      lastTime = now

   echo lastTime

main()
