# proc draw2d(archetype: Archetype): ptr UncheckedArray[Draw2d] {.inline.} =
#    assert HasDraw2d in archetype.kind
#    archetype.draw2d
#
# proc fade(archetype: Archetype): ptr UncheckedArray[Fade] {.inline.} =
#    assert HasFade in archetype.kind
#    archetype.fade
#
# proc move(archetype: Archetype): ptr UncheckedArray[Move] {.inline.} =
#    assert HasMove in archetype.kind
#    archetype.move
#
# proc shake(archetype: Archetype): ptr UncheckedArray[Shake] {.inline.} =
#    assert HasShake in archetype.kind
#    archetype.shake
#
# proc transform(archetype: Archetype): ptr UncheckedArray[Transform2d] {.inline.} =
#    assert HasTransform2d in archetype.kind
#    archetype.transform


proc `=`*(a: var Archetype; b: Archetype) =
   if a.data != b.data:
      `=destroy`(a)
      a.len = b.len
      a.kind = b.kind
      if b.data != nil:
         let cap = b.data.cap
         if a.kind == {HasShake, HasTransform2d}:
            a.data = cast[type(a.data)](allocShared0(
                  align(sizeof(ArchPayloadBase), alignof(Shake)) +
                  align(cap * sizeof(Shake), alignof(Transform2d)) +
                  cap * sizeof(Transform2d)))
            var dataPtr = result.data +!
                  align(sizeof(ArchPayloadBase), alignof(Shake))
            a.shake = cast[typeof(result.shake)](dataPtr)
            dataPtr = dataPtr +! align(cap * sizeof(Shake), alignof(Transform2d))
            a.transform = cast[typeof(result.transform)](dataPtr)
         else:
            a.data = cast[type(a.data)](allocShared0(
                  align(sizeof(ArchPayloadBase), alignof(Draw2d)) +
                  align(cap * sizeof(Draw2d), alignof(Fade)) +
                  align(cap * sizeof(Fade), alignof(Move)) +
                  align(cap * sizeof(Move), alignof(Shake)) +
                  align(cap * sizeof(Shake), alignof(Transform2d)) +
                  cap * sizeof(Transform2d)))
            a.draw2d =
            a.fade =
            a.move =
            a.shake =
            a.transform =
         a.data.cap = cap
         for i in 0 ..< a.len:
            if HasDraw2d in a.kind: a.draw2d[i] = b.draw2d[i]
            if HasFade in a.kind: a.fade[i] = b.fade[i]
            if HasMove in a.kind: a.move[i] = b.move[i]
            if HasShake in a.kind: a.shake[i] = b.shake[i]
            if HasTransform2d in a.kind: a.transform[i] = b.transform[i]
