import sdl2
export sdl2

type
   SdlContext[T] = object
      sdl: SdlContextRef
      impl: T

   WindowObj = object
      impl: WindowPtr
   Window* = SdlContext[WindowObj]

   RendererObj* = object
      impl: RendererPtr
   Renderer* = SdlContext[RendererObj]

   SdlContextRef* = ref SdlContextObj
   SdlContextObj = object

   ObjectAlreadyInitialized* = object of Defect
   SdlException* = object of Defect

var
   isSdlContextAlive: bool

proc `=destroy`(context: var SdlContextObj) =
   if isSdlContextAlive:
      sdl2.quit()
      isSdlContextAlive = false

proc sdlInit*(flags: cint): SdlContextRef =
   if isSdlContextAlive:
      raise newException(ObjectAlreadyInitialized,
            "Cannot initialize `SdlContext` more than once at a time.")
   else:
      if sdl2.init(flags) == SdlSuccess:
         # Initialize SDL without any explicit subsystems (flags = 0).
         isSdlContextAlive = true
         result = SdlContextRef()
      else:
         raise newException(SdlException, $getError())

proc `=destroy`(renderer: var RendererObj) =
   if renderer.impl != nil:
      destroy(renderer.impl)
proc `=`(renderer: var RendererObj; original: RendererObj) {.error.}

proc `=destroy`(window: var WindowObj) =
   if window.impl != nil:
      destroy(window.impl)
proc `=`(window: var WindowObj; original: WindowObj) {.error.}

proc get*(x: Window): WindowPtr = x.impl.impl
proc get*(x: Renderer): RendererPtr = x.impl.impl

proc newWindow*(sdl: SdlContextRef, title: string; x, y, w, h: cint; flags: uint32): Window =
   Window(sdl: sdl, impl: WindowObj(impl: createWindow(title, x, y, w, h, flags)))
proc newRenderer*(window: Window; index: cint; flags: cint): Renderer =
   Renderer(sdl: window.sdl, impl: RendererObj(impl: createRenderer(window.get, index, flags)))
