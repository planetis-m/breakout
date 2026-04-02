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

proc clearBackground*(color: Color) =
  clearBackgroundRaw(color)

proc drawRectangle*(x, y, width, height: int32; color: Color) =
  drawRectangleRaw(x.cint, y.cint, width.cint, height.cint, color)

export Color, KeyboardKey, KEY_A, KEY_D, KEY_ESCAPE, KEY_LEFT, KEY_RIGHT
