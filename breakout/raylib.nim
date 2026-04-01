import raylib_raw

type
  ObjectAlreadyInitialized* = object of Defect

  RaylibContext* = object
    notMoved: bool

var isRaylibContextAlive: bool

proc `=destroy`(context: var RaylibContext) =
  if isRaylibContextAlive and context.notMoved and isWindowReadyRaw():
    closeWindowRaw()
    isRaylibContextAlive = false

proc `=copy`(context: var RaylibContext; original: RaylibContext) {.error.}

func toColor(color: array[4, uint8]): Color =
  Color(r: color[0], g: color[1], b: color[2], a: color[3])

proc initRaylib*(title: string; width, height: int32): RaylibContext =
  if isRaylibContextAlive:
    raise newException(ObjectAlreadyInitialized,
      "Cannot initialize `RaylibContext` more than once at a time.")

  initWindowRaw(width.cint, height.cint, title.cstring)
  if not isWindowReadyRaw():
    raise newException(Defect, "raylib failed to initialize the window.")

  setExitKeyRaw(0)
  isRaylibContextAlive = true
  result = RaylibContext(notMoved: true)

proc pollInput*() =
  pollInputEventsRaw()

proc swapScreenBuffer*() =
  swapScreenBufferRaw()

proc waitTime*(seconds: float64) =
  waitTimeRaw(seconds.cdouble)

proc getTime*(): float64 =
  getTimeRaw().float64

proc windowShouldClose*(): bool =
  windowShouldCloseRaw()

proc keyDown*(key: KeyboardKey): bool =
  isKeyDownRaw(key.cint)

proc keyPressed*(key: KeyboardKey): bool =
  isKeyPressedRaw(key.cint)

proc beginDrawing*() =
  beginDrawingRaw()

proc endDrawing*() =
  endDrawingRaw()

proc clearBackground*(color: array[4, uint8]) =
  clearBackgroundRaw(toColor(color))

proc drawRectangle*(x, y, width, height: int32; color: array[4, uint8]) =
  drawRectangleRaw(x.cint, y.cint, width.cint, height.cint, toColor(color))

export KeyboardKey, KEY_A, KEY_D, KEY_ESCAPE, KEY_LEFT, KEY_RIGHT
