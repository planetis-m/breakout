import entities
from typetraits import supportsCopyMem

type
  Array*[T] = object
    data: ptr array[maxEntities, T]

proc `=destroy`*[T](x: var Array[T]) =
  if x.data != nil:
    when not supportsCopyMem(T):
      for i in 0..<maxEntities: `=destroy`(x[i])
    dealloc(x.data)
proc `=copy`*[T](dest: var Array[T], src: Array[T]) {.error.}

proc initArray*[T](): Array[T] =
  when not supportsCopyMem(T):
    result.data = cast[typeof(result.data)](alloc0(maxEntities * sizeof(T)))
  else:
    result.data = cast[typeof(result.data)](alloc(maxEntities * sizeof(T)))

template get(x, i) =
  rangeCheck x.p != nil and i.idx < x.len
  x.data[i]

proc `[]`*[T](x: Array[T]; i: Natural): lent T =
  get(x, i)
proc `[]`*[T](x: var Array[T]; i: Natural): var T =
  get(x, i)

proc `[]=`*[T](x: var Array[T]; i: Natural; y: sink T) =
  rangeCheck x.p != nil and i.idx < x.len
  x.data[i] = y

proc clear*[T](x: Array[T]) =
  when not supportsCopyMem(T):
    if x.data != nil:
      for i in 0..<maxEntities: reset(x[i])

proc `@`*[T](x: Array[T]): seq[T] {.inline.} =
  newSeq(result, x.len)
  for i in 0..x.len-1: result[i] = x[i]

template toOpenArray*(x: Array, first, last: int): untyped =
  toOpenArray(x.p, first, last)

template toOpenArray*(x: Array): untyped =
  toOpenArray(x.data, 0, x.len-1)
