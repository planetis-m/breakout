import std / [strutils, os]
export format

const
  stDebug = "\e[34;2m"
  stHint = "\e[32;2m"
  stWarn = "\e[33;2m"
  stError = "\e[31;2m"
  stFatal = "\e[35;2m"
  stInst = "\e[1m"
  stTraced = "\e[36;21m"
  resetCode = "\e[0m"
  sourceDir = currentSourcePath().parentDir()

type
  Level* {.pure.} = enum
    debug = stDebug & "Debug"
    hint = stHint & "Hint"
    warn = stWarn & "Warning"
    error = stError & "Error"
    fatal = stFatal & "Fatal"

var logLevel* = Level.debug

template log*(level: Level, args: varargs[string, `$`], filter: bool) =
  const
    info = instantiationInfo(fullPaths = true)
    module = relativePath(info.filename, sourceDir)
  if logLevel <= level and filter:
    stdout.write(format("$1$2($3)$5 $4:$5 ", stInst, module, info.line, level, resetCode))
    stdout.write(args)
    stdout.write(format("  $1[$2]$3\n", stTraced, astToStr(filter), resetCode))

template debug*(args: varargs[string, `$`], filter: bool) = log(Level.debug, args, filter)
template hint*(args: varargs[string, `$`], filter: bool) = log(Level.hint, args, filter)
template warn*(args: varargs[string, `$`], filter: bool) = log(Level.warn, args, filter)
template error*(args: varargs[string, `$`], filter: bool) = log(Level.error, args, filter)
template fatal*(args: varargs[string, `$`], filter: bool) = log(Level.fatal, args, filter)
