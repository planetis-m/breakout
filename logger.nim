import registry, std / strutils
export addf, format

const
  stDebug = "\e[34;2m"
  stHint = "\e[32;2m"
  stWarn = "\e[33;2m"
  stError = "\e[31;2m"
  stFatal = "\e[35;2m"
  stInst = "\e[1m"
  stTraced = "\e[36;21m"
  resetCode = "\e[0m"

type
  Level* = enum
    debug = stDebug & "Debug"
    hint = stHint & "Hint"
    warn = stWarn & "Warning"
    error = stError & "Error"
    fatal = stFatal & "Fatal"

var
  tick* = -1
  ent* = invalidId

template log*(level: Level, args: varargs[string, `$`]) =
  let (module, line, _) = instantiationInfo(fullPaths = true)
  var
    extra = ""
    keep = true
    comma = false
  if tick != -1:
    when compiles(game.tickId):
      if tick != game.tickId: keep = false
      else:
        extra.addf("Tick: $1", tick)
        comma = true
    else:
      comma = true
      extra.add("Tick not traced!")
  if ent != invalidId:
    when compiles(entity):
      if ent != entity: keep = false
      else:
        if comma: extra.add ", "
        extra.addf("Entity: $1", ent.EntityImpl)
    else:
      if comma: extra.add ", "
      extra.add("Entity not traced!")
  if keep:
    stdout.write(format("$1$2($3)$5 $4:$5 ", stInst, module, line, level, resetCode))
    stdout.write(args)
    if extra.len > 0:
      stdout.write(format("  $1[$2]$3", stTraced, extra, resetCode))
    stdout.write("\n")
