import entities
from typetraits import supportsCopyMem

type
  Array*[T] = object
    p: ptr array[maxEntities, T]

proc `=destroy`*[T](x: var Array[T]) =
  if x.p != nil:
    when not supportsCopyMem(T):
      for i in 0..<maxEntities: `=destroy`(x[i])
    when compileOption("threads"):
      deallocShared(x.p)
    else:
      dealloc(x.p)
proc `=copy`*[T](dest: var Array[T], src: Array[T]) {.error.}

proc initArray*[T](): Array[T] =
  when not supportsCopyMem(T):
    when compileOption("threads"):
      result.p = cast[typeof(result.p)](allocShared0(maxEntities * sizeof(T)))
    else:
      result.p = cast[typeof(result.p)](alloc0(maxEntities * sizeof(T)))
  else:
    when compileOption("threads"):
      result.p = cast[typeof(result.p)](allocShared(maxEntities * sizeof(T)))
    else:
      result.p = cast[typeof(result.p)](alloc(maxEntities * sizeof(T)))

template get(x, i) =
  rangeCheck x.p != nil and i < maxEntities
  x.p[i]

proc `[]`*[T](x: Array[T]; i: Natural): lent T =
  get(x, i)
proc `[]`*[T](x: var Array[T]; i: Natural): var T =
  get(x, i)

proc `[]=`*[T](x: var Array[T]; i: Natural; y: sink T) =
  rangeCheck x.p != nil and i < maxEntities
  x.p[i] = y

proc clear*[T](x: Array[T]) =
  when not supportsCopyMem(T):
    if x.p != nil:
      for i in 0..<maxEntities: reset(x[i])

proc `@`*[T](x: Array[T]): seq[T] {.inline.} =
  newSeq(result, maxEntities)
  for i in 0..<maxEntities: result[i] = x[i]

template toOpenArray*(x: Array, first, last: int): untyped =
  toOpenArray(x.p, first, last)

template toOpenArray*(x: Array): untyped =
  toOpenArray(x.p, 0, maxEntities-1)
