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

template initImpl(result: typed) =
  result.data = cast[typeof(result.data)](alloc(maxEntities * sizeof(T)))

proc initArray*[T](): Array[T] =
  initImpl(result)

template get(x, i) =
  when compileOption("boundChecks"):
    assert x.data != nil, "array not inititialized"
  x.data[i]

proc `[]`*[T](x: Array[T]; i: Natural): lent T =
  get(x, i)
proc `[]`*[T](x: var Array[T]; i: Natural): var T =
  get(x, i)

proc `[]=`*[T](x: var Array[T]; i: Natural; y: sink T) =
  if x.data == nil: initImpl(x)
  x.data[i] = y

proc clear*[T](x: Array[T]) =
  when not supportsCopyMem(T):
    if x.data != nil:
      for i in 0..<maxEntities: reset(x[i])

proc isNil*[T](x: Array[T]): bool = x.data == nil
