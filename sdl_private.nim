import sdl2
export sdl2

type
   SdlContext* = object

   Window* = object
      impl*: WindowPtr
   Renderer* = object
      impl*: RendererPtr

   ObjectAlreadyInitialized* = object of Defect
   SdlException* = object of Defect

var
   isSdlContextAlive: bool

proc `=destroy`(context: var SdlContext) =
   if isSdlContextAlive:
      sdl2.quit()
      isSdlContextAlive = false

proc sdlInit*(flags: cint): SdlContext =
   if isSdlContextAlive:
      raise newException(ObjectAlreadyInitialized,
            "Cannot initialize `SdlContext` more than once at a time.")
   else:
      if sdl2.init(flags) == SdlSuccess:
         # Initialize SDL without any explicit subsystems (flags = 0).
         isSdlContextAlive = true
         result = SdlContext()
      else:
         raise newException(SdlException, $getError())

proc `=destroy`(renderer: var Renderer) =
   if renderer.impl != nil:
      destroy(renderer.impl)
proc `=`(renderer: var Renderer; original: Renderer) {.error.}

proc `=destroy`(window: var Window) =
   if window.impl != nil:
      destroy(window.impl)
proc `=`(window: var Window; original: Window) {.error.}

proc newWindow*(title: string; x, y, w, h: cint; flags: uint32): Window =
   Window(impl: createWindow(title, x, y, w, h, flags))
proc newRenderer*(window: Window; index: cint; flags: cint): Renderer =
   Renderer(impl: createRenderer(window.impl, index, flags))
