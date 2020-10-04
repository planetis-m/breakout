## Delete once https://github.com/nim-lang/fusion/pull/8 is merged
type
   UniquePtr*[T] = object
      val: ptr T

proc `=destroy`*[T](p: var UniquePtr[T]) =
   mixin `=destroy`
   if p.val != nil:
      `=destroy`(p.val[])
      deallocShared(p.val)

proc `=`*[T](dest: var UniquePtr[T], src: UniquePtr[T]) {.error.}

proc newUniquePtr*[T](val: sink T): UniquePtr[T] {.nodestroy.} =
   result.val = cast[ptr T](allocShared(sizeof(T)))
   result.val[] = val

proc `[]`*[T](p: UniquePtr[T]): var T {.inline.} =
   when compileOption("boundChecks"):
      assert(p.val != nil, "deferencing nil unique pointer")
   p.val[]
