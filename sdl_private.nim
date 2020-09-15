when defined(windows):
   const LibName* = "SDL2.dll"
elif defined(macosx):
   const LibName* = "libSDL2.dylib"
elif defined(openbsd):
   const LibName* = "libSDL2.so.0.6"
else:
   const LibName* = "libSDL2.so"

type
   Subsystem* = enum
      Dummy, Timer, Audio = 4, Video, Joystick = 9, Haptic = 12, Gamecontroller, Events

   Scancode* = enum
      A = 4, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V,
      W, X, Y, Z, Num1, Num2, Num3, Num4, Num5, Num6, Num7, Num8, Num9, Num0,
      Return, Escape, Backspace, Tab, Space, Minus, Equals, LeftBracket,
      RightBracket, Backslash, NonUsHash, Semicolon, Apostrophe, Grave,
      Comma, Period, Slash, CapsLock, F1, F2, F3, F4, F5, F6, F7, F8, F9,
      F10, F11, F12, PrintScreen, ScrollLock, Pause, Insert, Home, PageUp,
      Delete, End, PageDown, Right, Left, Down, Up, NumLockClear, KpDivide,
      KpMultiply, KpMinus, KpPlus, KpEnter, Kp1, Kp2, Kp3, Kp4, Kp5, Kp6,
      Kp7, Kp8, Kp9, Kp0, KpPeriod, NonUsBackslash, Application, Power,
      KpEquals, F13, F14, F15, F16, F17, F18, F19, F20, F21, F22, F23,
      F24, Execute, Help, Menu, Select, Stop, Again, Undo, Cut, Copy,
      Paste, Find, Mute, VolumeUp, VolumeDown, KpComma, KpEqualsAS400,
      International1, International2, International3, International4,
      International5, International6, International7, International8,
      International9, Lang1, Lang2, Lang3, Lang4, Lang5, Lang6, Lang7,
      Lang8, Lang9, AltErase, SysReq, Cancel, Clear, Prior, Return2,
      Separator, Out, Oper, ClearAgain, CrSel, ExSel, Kp00, Kp000,
      ThousandsSeparator, DecimalSeparator, CurrencyUnit, CurrencySubUnit,
      KpLeftParen, KpRightParen, KpLeftBrace, KpRightBrace, KpTab,
      KpBackspace, KpA, KpB, KpC, KpD, KpE, KpF, KpXor, KpPower,
      KpPercent, KpLess, KpGreater, KpAmpersand, KpDblAmpersand,
      KpVerticalBar, KpDblVerticalBar, KpColon, KpHash, KpSpace, KpAt,
      KpExclam, KpMemStore, KpMemRecall, KpMemClear, KpMemAdd,
      KpMemSubtract, KpMemMultiply, KpMemDivide, KpPlusMinus, KpClear,
      KpClearEntry, KpBinary, KpOctal, KpDecimal, KpHexadecimal, LCtrl,
      LShift, LAlt, LGui, RCtrl, RShift, RAlt, RGui, Mode, AudioNext,
      AudioPrev, AudioStop, AudioPlay, AudioMute, MediaSelect, Www, Mail,
      Calculator, Computer, AcSearch, AcHome, AcBack, AcForward, AcStop,
      AcRefresh, AcBookmarks, BrightnessDown, BrightnessUp, DisplaySwitch,
      KbdIllumToggle, KbdIllumDown, KbdIllumUp, Eject, Sleep, App1, App2

   WindowEvent* = enum
      None, Shown, Hidden, Exposed,
      Moved, Resized, SizeChanged, Minimized,
      Maximized, Restored, Enter, Leave,
      FocusGained, FocusLost, Close,
      TakeFocus, HitTest

   MouseButton* = enum
      Unknown, Left, Middle, Right, X1, X2

   MouseWheelDirection* = enum
      Normal, Flipped

   MouseState* = object
      mouseState*: uint32
      x*, y*: int32

   EventKind* = enum
      First, QuitEvent = 0x100, AppTerminating, AppLowMemory, AppWillEnterBackground,
      AppDidEnterBackground, AppWillEnterForeground, AppDidEnterForeground,
      DisplayEvent = 0x150,
      WindowEvent = 0x200, SysWMEvent,
      KeyDown = 0x300, KeyUp, TextEditing, TextInput, KeymapChanged,
      MouseMotion = 0x400, MouseButtonDown, MouseButtonUp, MouseWheel,
      JoyAxisMotion = 0x600, JoyBallMotion, JoyHatMotion, JoyButtonDown,
      JoyButtonUp, JoyDeviceAdded, JoyDeviceRemoved,
      ControllerAxisMotion = 0x650, ControllerButtonDown, ControllerButtonUp,
      ControllerDeviceAdded, ControllerDeviceRemoved, ControllerDeviceRemapped,
      FingerDown = 0x700, FingerUp, FingerMotion,
      DollarGesture = 0x800, DollarRecord, MultiGesture,
      ClipboardUpdate = 0x900,
      DropFile = 0x1000,  DropText, DropBegin, DropComplete,
      AudioDeviceAdded = 0x1100, AudioDeviceRemoved = 0x1101,
      SensorUpdate = 0x1200,
      RenderTargetsReset = 0x2000, RenderDeviceReset,
      User = 0x8000, User1, User2, User3, User4, User5, Last = 0xFFFF,

   Event* = object
      timestamp*: uint32
      case kind*: EventKind
      of Quit, AppTerminating, AppLowMemory,
            AppWillEnterBackground, AppDidEnterBackground,
            AppWillEnterForeground, AppDidEnterForeground, ClipboardUpdate, Unknown: discard
      of Window:
         #windowId*: uint32
         event*: WindowEvent
      of KeyDown, KeyUp:
         #windowId*: uint32
         #keycode*: Option[Keycode]
         scancode*: Option[Scancode]
         keymod*: Keymod
         repeat*: bool
      of TextEditing:
         #windowId*: uint32
         text*: string
         start*: int32
         length*: int32
      of TextInput:
         #windowId*: uint32
         text*: string
      of MouseMotion:
         #windowId*: uint32
         #which*: uint32
         mouseState*: MouseState
         x*, y*: int32
         xrel*, yrel*: int32
      of MouseButtonDown, MouseButtonUp:
         #windowId*: uint32
         #which*: uint32
         mouseBtn*: MouseButton
         clicks*: uint8
         x*, y*: int32
      of MouseWheel:
         #windowId*: uint32
         #which*: uint32
         x*, y*: int32
         direction*: MouseWheelDirection
      of JoyAxisMotion:
         #which*: int32 ## The joystick's `id`
         axisIdx*: uint8
         value*: int16
      of JoyBallMotion:
         #which*: int32 ## The joystick's `id`
         ballIdx*: uint8
         xrel*, yrel*: int16
      of JoyHatMotion:
         #which*: int32 ## The joystick's `id`
         hatIdx*: uint8
         state*: HatState
      of JoyButtonDown, JoyButtonUp:
         #which*: int32 ## The joystick's `id`
         buttonIdx*: uint8
      of JoyDeviceAdded, JoyDeviceRemoved:
         #which*: uint32 ## The joystick's `id`
      of ControllerAxisMotion:
         #which*: int32 ## The controller's joystick `id`
         axis*: Axis
         value*: int16
      of ControllerButtonDown, ControllerButtonUp:
         #which*: int32 ## The controller's joystick `id`
         button*: Button
      of ControllerDeviceAdded, ControllerDeviceRemoved, ControllerDeviceRemapped:
         which*: uint32 ## The newly added controller's `joystick_index`
      of FingerDown, FingerUp, FingerMotion:
         #touchId*: int64
         fingerId*: int64
         x*, y*: float32
         dx*, dy*: float32
         pressure*: float32
      of DollarGesture, DollarRecord:
         #touchId*: int64
         gestureId*: int64
         numFingers*: uint32
         error*: float32
         x*, y*: float32
      of MultiGesture:
         #touchId*: int64
         dTheta*: float32
         dDist*: float32
         x*, y*: float32
         numFingers*: uint16
      of DropFile:
         #windowId*: uint32
         filename*: string
      of User:
         #windowId*: uint32
         code*: int32
         data1*, data2*: pointer

   Canvas* = object
      target*: Window
      context*: Renderer

   Window* = object
      impl: WindowPtr

   Renderer* = object
      impl: RendererPtr

   SdlContext* = ref SdlContextObj
   SdlContextObj = object

   EventPump* = ref EventPumpObj
   EventPumpObj = object
      sdl: SdlContext

   ObjectAlreadyInitialized* = object of Defect
   SdlError* = object of CatchableError

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
      if SDL_Init(0) == 0:
         # Initialize SDL without any explicit subsystems (flags = 0).
         isSdlContextAlive = true
         result = SdlContext()
      else:
         raise newException(SdlError, $SDL_getError())

template subsystem(system, flag: untyped, noCopy = true) =
   type
      system* = ref `system Obj`
      `system Obj` = object
         sdl: SdlContext

   proc `=destroy`(self: var `system Obj`) =
      SDL_QuitSubSystem(flag)
   when noCopy:
      proc `=`(self: var `system Obj`; original: `system Obj`) {.error.}

   proc `init flag`*(context: SdlContext): system =
      if SDL_InitSubSystem(flag) == 0:
         result = system(sdl: SdlContext)
      else:
         raise newException(SdlError, $SDL_getError())

subsystem(AudioSubsystem, Audio)
subsystem(GameControllerSubsystem, Gamecontroller)
subsystem(HapticSubsystem, Haptic)
subsystem(JoystickSubsystem, Joystick)
subsystem(VideoSubsystem, Video)
# Timers can be added on other threads.
subsystem(TimerSubsystem, Timer, false)
# The event queue can be read from other threads.
subsystem(EventSubsystem, Events, false)

proc `=destroy`(context: var EventPumpObj) =
   assert isEventPumpAlive
   SDL_QuitSubSystem(Events)
   isEventPumpAlive = false

proc initEventPump*(context: SdlContext): EventPump =
   if isEventPumpAlive:
      raise newException(ObjectAlreadyInitialized,
            "Cannot initialize `EventPump` more than once at a time.")
   else:
      if SDL_InitSubSystem(Events) == 0:
         isEventPumpAlive = true
         result = EventPump(sdl: SdlContext)
      else:
         raise newException(SdlError, $SDL_getError())

proc `=destroy`(renderer: var Renderer) =
   if renderer.impl != nil:
      SDL_destroyRenderer(renderer.impl)
proc `=`(renderer: var Renderer; original: Renderer) {.error.}

proc `=destroy`(window: var Window) =
   if window.impl != nil:
      SDL_destroyWindow(window.impl)
proc `=`(window: var Window; original: Window) {.error.}
