import macros

let entity = game.blueprint:
   translation = Vec2(x: x, y: y)
   rotation = 2.0'f32
   scale = Vec2(x: 0.5, y: 0.5)
   parent = game.camera
   with:
      collide(size = Vec2(x: 20.0, y: 20.0))
      controlBall(angle)
      controlBrick()
      controlPaddle()
      draw2d(20, 20, [255'u8, 255, 0, 255])
      fade(0.0)
      move(direction = Vec2(x: 1.0, y: 1.0), speed = 600.0)
      shake(0.0, 20.0)
   children:
      entity(ball(float32(game.windowWidth / 2), float32(game.windowHeight - 60)))
      for i in 0 ..< explosions:
         blueprint:
            with:
               draw2d(20, 20, [255'u8, 255, 255, 255])
               fade(fadeStep)
               move(Vec2(x: sin(step * i), y: cos(step * i)), 800.0)
#[
let entity =
   let result = createEntity(game)
   mixCollide(game, result, Vec2(x: 20.0, y: 20.0))
   mixControlBall(game, result, angle)
   mixControlBrick(game, result)
   mixControlPaddle(game, result)
   mixDraw2d(game, result, 20, 20, [255'u8, 255, 0, 255])
   mixFade(game, result, 0.0)
   mixMove(game, result, Vec2(x: 1.0, y: 1.0), 600.0)
   mixShake(game, result, 0.0, 20.0)
   var children: seq[int]
   add(children, ball(game, result, float32(game.windowWidth / 2), float32(game.windowHeight - 60)))
   for i in 0 ..< explosions:
      let temp = createEntity(game)
      mixDraw2d(game, temp, 20, 20, [255'u8, 255, 255, 255])
      mixFade(game, temp, fadeStep)
      mixMove(game, temp, Vec2(x: sin(step * i), y: cos(step * i)), 800.0)
      mixTransform2d(game, temp, parent = result)
      add(children, temp)
   mixTransform2d(game, result, translation = Vec2(x: x, y: y),
         rotation = 2.0'f32, scale = Vec2(x: 0.5, y: 0.5), parent = game.camera, children = children)
   if game.camera != -1: game.addChild(parent = game.camera, result)
   result
]#

proc transformChildren(n, game: NimNode): NimNode =

proc blueprintImpl(game, parent, body: NimNode): NimNode =
   expectKind body, nnkStmtList
   expectMinLen body, 1

   if n.kind in nnkCallKinds and n[0].kind == nnkIdent:
      case $n[0]
      of "with":
      of "children":
         expectLen n, 2
         let q = transformChildren(game, n[1])
         result = nnkStmtListExpr.newTree()
         return
   result = copyNimNode(n)
   for i in 0 ..< n.len:
      result.add blueprintImpl(n[i], b)

macro blueprint(game: Game, body: untyped): int =
   result = blueprintImpl(game, newTree(nnkNone), body)
   echo result.repr
