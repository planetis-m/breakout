import registry

type
   Array*[T] = object
      data: ptr array[maxEntities, T]

proc `=destroy`*[T](x: var Array[T]) =
   if x.data != nil:
      for i in 0..<maxEntities: `=destroy`(x[i])
      dealloc(x.data)

proc `=copy`*[T](dest: var Array[T], src: Array[T]) {.error.}

proc `[]`*[T](x: Array[T]; i: Natural): lent T =
   assert i < maxEntities
   x.data[i]

proc `[]`*[T](x: var Array[T]; i: Natural): var T =
   assert i < maxEntities
   x.data[i]

proc `[]=`*[T](x: var Array[T]; i: Natural; y: sink T) =
   assert i < maxEntities
   x.data[i] = y

proc initArray*[T](): Array[T] =
  result.data = cast[typeof(result.data)](alloc(maxEntities * sizeof(T)))
