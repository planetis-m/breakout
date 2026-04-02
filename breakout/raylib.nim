import raylib_raw

proc initRaylib*(title: string; width, height: int32) =
  initWindowRaw(width.cint, height.cint, title.cstring)
  if not isWindowReadyRaw():
    raise newException(Defect, "raylib failed to initialize the window.")

  setExitKeyRaw(0)

proc closeRaylib*() =
  closeWindowRaw()

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
