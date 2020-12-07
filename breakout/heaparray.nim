import registry

type
   Array*[T] = object
      data: ptr array[maxEntities, T]

proc `=destroy`*[T](x: var Array[T]) =
   if x.data != nil:
      for i in 0..<maxEntities: `=destroy`(x[i])
      dealloc(x.data)

proc `=copy`*[T](dest: var Array[T], src: Array[T]) {.error.}

template initImpl(result: typed) =
   result.data = cast[typeof(result.data)](alloc(maxEntities * sizeof(T)))

proc initArray*[T](): Array[T] =
   initImpl(result)

proc `[]`*[T](x: Array[T]; i: Natural): lent T =
   when compileOption("boundChecks"):
      assert x.data != nil and i < maxEntities, "index out of bounds"
   x.data[i]

proc `[]`*[T](x: var Array[T]; i: Natural): var T =
   when compileOption("boundChecks"):
      assert x.data != nil and i < maxEntities, "index out of bounds"
   x.data[i]

proc `[]=`*[T](x: var Array[T]; i: Natural; y: sink T) =
   when compileOption("boundChecks"):
      assert i < maxEntities, "index out of bounds"
   if x.data == nil: initImpl(x)
   x.data[i] = y
