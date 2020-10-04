import sdl2
export sdl2

type
   SdlPtr[T] = object
      sdl: SdlContext
      x: T

   Window* = object
      sdl: SdlContext
      impl: WindowPtr

   Renderer* = object
      sdl: SdlContext
      impl: RendererPtr

   SdlContext* = ref SdlContextObj
   SdlContextObj = object

   EventPump* = ref EventPumpObj
   EventPumpObj = object
      sdl: SdlContext

   ObjectAlreadyInitialized* = object of Defect
   SdlException* = object of Defect

var
   isSdlContextAlive: bool
   isEventPumpAlive: bool

proc `=destroy`(context: var SdlContextObj) =
   assert isSdlContextAlive
   SDL_quit()
   isSdlContextAlive = false

proc initSdl*(): SdlContext =
   if isSdlContextAlive:
      raise newException(ObjectAlreadyInitialized,
            "Cannot initialize `SdlContext` more than once at a time.")
   else:
      if sdl2.init(0) == SdlSuccess:
         # Initialize SDL without any explicit subsystems (flags = 0).
         isSdlContextAlive = true
         result = SdlContext()
      else:
         raise newException(SdlException, $getError())

template subsystem(system, flag: untyped) =
   type
      `system Subsystem`* = object
         sdl: SdlContext

   proc `=destroy`(self: var `system Subsystem`) =
      quitSubSystem(flag)
      `=destroy`(self.sdl)
   proc `=`(self: var `system Subsystem`; original: `system Subsystem`) {.error.}

   proc `init system`*(context: SdlContext): `system Subsystem` =
      if initSubSystem(flag) == 0:
         result = `system Subsystem`(sdl: SdlContext)
      else:
         raise newException(SdlException, $getError())

subsystem(Audio, INIT_AUDIO)
subsystem(GameController, INIT_GAMECONTROLLER)
subsystem(Haptic, INIT_HAPTIC)
subsystem(Joystick, INIT_JOYSTICK)
subsystem(Video, INIT_VIDEO)
subsystem(Timer, INIT_TIMER)
subsystem(Event, INIT_EVENTS)

proc `=destroy`(context: var EventPumpObj) =
   assert isEventPumpAlive
   quitSubSystem(INIT_EVENTS)
   isEventPumpAlive = false

proc initEventPump*(context: SdlContext): EventPump =
   if isEventPumpAlive:
      raise newException(ObjectAlreadyInitialized,
            "Cannot initialize `EventPump` more than once at a time.")
   else:
      if initSubSystem(INIT_EVENTS) == 0:
         isEventPumpAlive = true
         result = EventPump(sdl: SdlContext)
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

proc pollEvent*(self: EventPump, event: Event): bool =
proc pumpEvents*(self: EventPump) = pumpEvents()
