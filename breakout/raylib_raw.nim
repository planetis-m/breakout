import std/os

const ProjectRoot = currentSourcePath.parentDir.parentDir

{.passc: "-DSUPPORT_CUSTOM_FRAME_CONTROL=1".}

when defined(linux):
  {.passc: "-I\"" & ProjectRoot & "\"".}
  {.passl: "-L\"" & ProjectRoot & "\" -lraylib -Wl,-rpath,\\$ORIGIN".}
elif defined(macosx):
  {.passc: "-I\"" & ProjectRoot & "\"".}
  {.passl: "-L\"" & ProjectRoot & "\" -lraylib".}
elif defined(windows):
  const VcpkgRoot {.strdefine.} = ""
  when VcpkgRoot.len == 0:
    {.error: "Define VcpkgRoot for Windows builds (for example: -d:VcpkgRoot=%VCPKG_ROOT%)".}
  {.passc: "-I\"" & ProjectRoot & "\" -I\"" & VcpkgRoot / "include" & "\"".}
  {.passl: "/link /LIBPATH:\"" & VcpkgRoot / "lib" & "\" raylib.lib user32.lib gdi32.lib winmm.lib shell32.lib".}
else:
  {.error: "Unsupported platform".}

type
  Color* {.bycopy, importc: "Color", header: "raylib.h".} = object
    r*, g*, b*, a*: uint8

  KeyboardKey* = cint

const
  KEY_A* = KeyboardKey(65)
  KEY_D* = KeyboardKey(68)
  KEY_ESCAPE* = KeyboardKey(256)
  KEY_RIGHT* = KeyboardKey(262)
  KEY_LEFT* = KeyboardKey(263)

{.push callconv: cdecl, header: "raylib.h".}

proc initWindowRaw*(width, height: cint; title: cstring) {.importc: "InitWindow".}
proc closeWindowRaw*() {.importc: "CloseWindow".}
proc isWindowReadyRaw*(): bool {.importc: "IsWindowReady".}
proc windowShouldCloseRaw*(): bool {.importc: "WindowShouldClose".}
proc setExitKeyRaw*(key: cint) {.importc: "SetExitKey".}
proc pollInputEventsRaw*() {.importc: "PollInputEvents".}
proc swapScreenBufferRaw*() {.importc: "SwapScreenBuffer".}
proc waitTimeRaw*(seconds: cdouble) {.importc: "WaitTime".}
proc getTimeRaw*(): cdouble {.importc: "GetTime".}
proc beginDrawingRaw*() {.importc: "BeginDrawing".}
proc endDrawingRaw*() {.importc: "EndDrawing".}
proc clearBackgroundRaw*(color: Color) {.importc: "ClearBackground".}
proc drawRectangleRaw*(posX, posY, width, height: cint; color: Color) {.importc: "DrawRectangle".}
proc isKeyDownRaw*(key: cint): bool {.importc: "IsKeyDown".}
proc isKeyPressedRaw*(key: cint): bool {.importc: "IsKeyPressed".}

{.pop.}
