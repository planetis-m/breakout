import registry, std / [strutils, os]

var
  tickId* = -1
  traced* = EntityImpl(invalidId)

template debug*(args: varargs[string, `$`]) =
  let (module, line, _) = instantiationInfo()
  var keep = true
  if tickId != -1:
    when compiles(game.tickId):
      if tickId != game.tickId: keep = false
    else: {.warning: "no game.tickId found".}
  if traced != invalidId:
    when compiles(entity):
      if traced != entity: keep = false
    else: {.warning: "no entity found".}
  if keep:
    echo(module.changeFileExt(""), ":", line, " ", join(args))
