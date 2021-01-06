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

proc raiseSdl*(msg: string) {.noreturn.} =
  ## Raises a `SdlException` exception with message `msg`.
  raise newException(SdlException, msg)

proc `=destroy`(context: var SdlContext) =
  if isSdlContextAlive:
    sdl2.quit()
    isSdlContextAlive = false
proc `=copy`(context: var SdlContext; original: SdlContext) {.error.}

proc `=destroy`(renderer: var Renderer) =
  if renderer.impl != nil:
    destroy(renderer.impl)
proc `=copy`(renderer: var Renderer; original: Renderer) {.error.}

proc `=destroy`(window: var Window) =
  if window.impl != nil:
    destroy(window.impl)
proc `=copy`(window: var Window; original: Window) {.error.}

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
      raiseSdl($getError())

proc newWindow*(title: string; x, y, w, h: cint; flags: uint32): Window =
  let impl = createWindow(title, x, y, w, h, flags)
  if impl != nil:
    result = Window(impl: impl)
  else:
    raiseSdl($getError())

proc newRenderer*(window: Window; index: cint; flags: cint): Renderer =
  let impl = createRenderer(window.impl, index, flags)
  if impl != nil:
    result = Renderer(impl: impl)
  else:
    raiseSdl($getError())
