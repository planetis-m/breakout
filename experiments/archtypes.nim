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
      data: ptr ArchPayloadBase

   ArchPayloadBase = object
      cap: int

template `+!`(p: pointer, s: int): pointer =
   cast[pointer](cast[int](p) +% s)

proc align(address, alignment: int): int =
   result = (address + (alignment - 1)) and not (alignment - 1)

proc draw2d(archetype: Archetype): ptr UncheckedArray[Draw2d] {.inline.} =
   let cap = archetype.data.cap
   if archetype.kind == {HasShake, HasTransform2d}:
      nil
#    elif archetype.kind == {HasDraw2d, HasFade, HasMove, HasShake, HasTransform2d}:
   else:
      cast[ptr UncheckedArray[Draw2d]](archetype.data +!
            align(sizeof(ArchPayloadBase), alignof(Draw2d)))

proc fade(archetype: Archetype): ptr UncheckedArray[Fade] {.inline.} =
   let cap = archetype.data.cap
   if archetype.kind == {HasShake, HasTransform2d}:
      nil
#    elif archetype.kind == {HasDraw2d, HasFade, HasMove, HasShake, HasTransform2d}:
   else:
      cast[ptr UncheckedArray[Fade]](archetype.data +!
            align(sizeof(ArchPayloadBase), alignof(Draw2d)) +!
            align(cap * sizeof(Draw2d), alignof(Fade)))

proc move(archetype: Archetype): ptr UncheckedArray[Move] {.inline.} =
   let cap = archetype.data.cap
   if archetype.kind == {HasShake, HasTransform2d}:
      nil
#    elif archetype.kind == {HasDraw2d, HasFade, HasMove, HasShake, HasTransform2d}:
   else:
      cast[ptr UncheckedArray[Move]](archetype.data +!
            align(sizeof(ArchPayloadBase), alignof(Draw2d)) +!
            align(cap * sizeof(Draw2d), alignof(Fade)) +!
            align(cap * sizeof(Fade), alignof(Move)))

proc shake(archetype: Archetype): ptr UncheckedArray[Shake] {.inline.} =
   let cap = archetype.data.cap
   if archetype.kind == {HasShake, HasTransform2d}:
      cast[ptr UncheckedArray[Shake]](archetype.data +!
            align(sizeof(ArchPayloadBase), alignof(Shake)))
#    elif archetype.kind == {HasDraw2d, HasFade, HasMove, HasShake, HasTransform2d}:
   else:
      cast[ptr UncheckedArray[Shake]](archetype.data +!
            align(sizeof(ArchPayloadBase), alignof(Draw2d)) +!
            align(cap * sizeof(Draw2d), alignof(Fade)) +!
            align(cap * sizeof(Fade), alignof(Move)) +!
            align(cap * sizeof(Move), alignof(Shake)))

proc transform(archetype: Archetype): ptr UncheckedArray[Transform2d] {.inline.} =
   let cap = archetype.data.cap
   if archetype.kind == {HasShake, HasTransform2d}:
      cast[ptr UncheckedArray[Transform2d]](archetype.data +!
            align(sizeof(ArchPayloadBase), alignof(Shake)) +!
            cap * sizeof(Transform2d))
#    elif archetype.kind == {HasDraw2d, HasFade, HasMove, HasShake, HasTransform2d}:
   else:
      cast[ptr UncheckedArray[Transform2d]](archetype.data +!
            align(sizeof(ArchPayloadBase), alignof(Draw2d)) +!
            align(cap * sizeof(Draw2d), alignof(Fade)) +!
            align(cap * sizeof(Fade), alignof(Move)) +!
            align(cap * sizeof(Move), alignof(Shake)) +!
            cap * sizeof(Transform2d))

proc `=destroy`*(x: var Archetype) =
   if x.data != nil:
      for i in 0 ..< x.len:
         if HasDraw2d in x.kind: `=destroy`(x.draw2d[i])
         if HasFade in x.kind: `=destroy`(x.fade[i])
         if HasMove in x.kind: `=destroy`(x.move[i])
         if HasShake in x.kind: `=destroy`(x.shake[i])
         if HasTransform2d in x.kind: `=destroy`(x.transform[i])
      dealloc(x.data)
      x.data = nil

proc `=`*(a: var Archetype; b: Archetype) {.error.}

proc newArchPayload1(cap: int): ptr ArchPayloadBase =
   # we have to use type erasure here as Nim does not support generic
   # compilerProcs. Oh well, this will all be inlined anyway.
   if cap > 0:
      var p = cast[ptr ArchPayloadBase](allocShared0(align(sizeof(ArchPayloadBase), alignof(Shake)) +
            align(cap * sizeof(Shake), alignof(Transform2d)) + cap * sizeof(Transform2d)))
      p.cap = cap
      result = p
   else:
      result = nil

proc newArchPayload2(cap: int): ptr ArchPayloadBase =
   # we have to use type erasure here as Nim does not support generic
   # compilerProcs. Oh well, this will all be inlined anyway.
   if cap > 0:
      var p = cast[ptr ArchPayloadBase](allocShared0(align(sizeof(ArchPayloadBase), alignof(Draw2d)) +
            align(cap * sizeof(Draw2d), alignof(Fade)) +
            align(cap * sizeof(Fade), alignof(Move)) +
            align(cap * sizeof(Move), alignof(Shake)) +
            align(cap * sizeof(Shake), alignof(Transform2d)) +
            cap * sizeof(Transform2d)))
      p.cap = cap
      result = p
   else:
      result = nil

# proc prepareArchAdd(len: int; p: pointer; addlen, elemSize: int): pointer =
#
#    let headerSize = sizeof(NimSeqPayloadBase)
#    if p == nil:
#       result = newSeqPayload(len + addlen, elemSize)
#    else:
#       # Note: this means we cannot support things that have internal pointers as
#       # they get reallocated here. This needs to be documented clearly.
#       var p = cast[ptr NimSeqPayloadBase](p)
#       let oldCap = p.cap
#       let newCap = max(oldCap, len + addlen)
#
#       let oldSize = headerSize + elemSize * oldCap
#       let newSize = headerSize + elemSize * newCap
#       var q = cast[ptr NimSeqPayloadBase](reallocShared0(p, oldSize, newSize))
#       q.cap = newCap
#       result = q
import std / [times, monotimes]

proc main =
   var lastTime = getMonoTime()
   var archetypes = [
      Archetype(kind: {HasShake, HasTransform2d}, len: 1000, data: newArchPayload1(1000)),
      Archetype(kind: {HasDraw2d, HasFade, HasMove, HasShake, HasTransform2d},
            len: 2000, data: newArchPayload2(2000))]
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
