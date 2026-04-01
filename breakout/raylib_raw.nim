import std/os

const ProjectRoot = currentSourcePath.parentDir.parentDir

when defined(linux):
  {.passc: "-I\"" & ProjectRoot & "\"".}
  {.passl: "-L\"" & ProjectRoot & "\" -lraylib -Wl,-rpath,\\$ORIGIN".}
elif defined(macosx):
  {.passc: "-I\"" & ProjectRoot & "\"".}
  {.passl: "-L\"" & ProjectRoot & "\" -lraylib".}
elif defined(windows):
  {.passc: "-I\"" & ProjectRoot & "\"".}
  {.passl: "/LIBPATH:\"" & ProjectRoot & "\" raylib.lib user32.lib gdi32.lib winmm.lib shell32.lib".}
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

proc initWindowRaw*(width, height: cint; title: cstring) {.
    importc: "InitWindow", cdecl, header: "raylib.h".}
proc closeWindowRaw*() {.
    importc: "CloseWindow", cdecl, header: "raylib.h".}
proc isWindowReadyRaw*(): bool {.
    importc: "IsWindowReady", cdecl, header: "raylib.h".}
proc windowShouldCloseRaw*(): bool {.
    importc: "WindowShouldClose", cdecl, header: "raylib.h".}
proc setExitKeyRaw*(key: cint) {.
    importc: "SetExitKey", cdecl, header: "raylib.h".}
proc pollInputEventsRaw*() {.
    importc: "PollInputEvents", cdecl, header: "raylib.h".}
proc beginDrawingRaw*() {.
    importc: "BeginDrawing", cdecl, header: "raylib.h".}
proc endDrawingRaw*() {.
    importc: "EndDrawing", cdecl, header: "raylib.h".}
proc clearBackgroundRaw*(color: Color) {.
    importc: "ClearBackground", cdecl, header: "raylib.h".}
proc drawRectangleRaw*(posX, posY, width, height: cint; color: Color) {.
    importc: "DrawRectangle", cdecl, header: "raylib.h".}
proc isKeyDownRaw*(key: cint): bool {.
    importc: "IsKeyDown", cdecl, header: "raylib.h".}
proc isKeyPressedRaw*(key: cint): bool {.
    importc: "IsKeyPressed", cdecl, header: "raylib.h".}
