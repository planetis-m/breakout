import
  gametypes, utils, mixins, vmath, loaddsl,
  std/[parsejson, streams, strutils], eminim, eminim/jsmartptrs
from typetraits import distinctBase

proc initFromJson*[T: distinct](dst: var T; p: var JsonParser) =
  initFromJson(dst.distinctBase, p)

proc loadAsset*(world: var World; entity, parent: Entity; p: var JsonParser) =
  dispatch(world, entity, p):
    proc onCollide(size = vec2(0, 0))
    proc onControlBall
    proc onControlBrick
    proc onControlPaddle
    proc onDraw2d(width, height = 100'i32, color = [255'u8, 0, 255, 255])
    proc onFade(step = 0.0)
    proc onMove(direction = vec2(0, 0), speed = 10.0)
    proc onShake(duration = 1.0, strength = 0.0)
    proc onTransform2d(trworld = mat2d(), translation = vec2(0, 0),
        rotation = 0.Rad, scale = vec2(1, 1), parent = parent)

template readArray(parser, body) =
  eat(parser, tkBracketLe)
  while parser.tok != tkBracketRi:
    body
    if parser.tok != tkComma: break
    discard getTok(parser)
  eat(parser, tkBracketRi)

proc blueprintJson*(dst: var World; entity, parent: Entity; p: var JsonParser) =
  eat(p, tkCurlyLe)
  while p.tok != tkCurlyRi:
    if p.tok != tkString:
      raiseParseErr(p, "string literal as key")
    case nimIdentNormalize(p.a)
    of "with":
      discard getTok(p)
      eat(p, tkColon)
      readArray(p):
        loadAsset(dst, entity, parent, p)
    of "children":
      discard getTok(p)
      eat(p, tkColon)
      readArray(p):
        let tmp = createEntity(dst)
        blueprintJson(dst, tmp, entity, p)
    else:
      raiseParseErr(p, "valid object field")
    if p.tok != tkComma: break
    discard getTok(p)
  eat(p, tkCurlyRi)

proc jsonBuild*(s: Stream, game: var Game, parent: Entity): Entity =
  var p: JsonParser
  open(p, s, "unknown file")
  try:
    discard getTok(p)
    result = createEntity(game.world)
    blueprintJson(game.world, result, parent, p)
    eat(p, tkEof)
  finally:
    close(p)

proc loadScene*(game: var Game; assetfile: string) =
  let fs = newFileStream(assetfile)
  if fs != nil:
    game.camera = jsonBuild(fs, game, invalidId)
