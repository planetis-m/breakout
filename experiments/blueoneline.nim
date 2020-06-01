import ".."/[game_types, vmath, utils]
import ".."/dsl except addBlueprint
import macros

# ---------------
# Blueprint macro
# ---------------

proc blueprintImpl(game, entity, transform, hierarchy, n: NimNode): NimNode

proc transformBlueprint(result, game, entity, parent, n: NimNode, i: int) =
   proc handleStmtList(result, game, entity, transform, hierarchy, n: NimNode) =
      for a in n:
         if a.kind in {nnkStmtList, nnkStmtListExpr}:
            handleStmtList(result, game, entity, transform, hierarchy, a)
         else:
            let t = blueprintImpl(game, entity, transform, hierarchy, a)
            if t.kind != nnkNone: result.add t

   let transform = newTree(nnkCall, bindSym"mixTransform2d", game, entity)
   let hierarchy = newTree(nnkCall, bindSym"mixHierarchy", game, entity)
   var resBody = newStmtList()
   if n.len == i + 1 and n[i].kind in {nnkStmtList, nnkStmtListExpr}:
      handleStmtList(resBody, game, entity, transform, hierarchy, n[i])
   else:
      for j in i ..< n.len:
         let t = blueprintImpl(game, entity, transform, hierarchy, n[j])
         if t.kind != nnkNone: resBody.add t

   if parent.kind != nnkNone and hierarchy.len == 3: hierarchy.add parent
   result.add(newLetStmt(entity, newTree(nnkCall, bindSym"createEntity", game)),
         transform, hierarchy, newTree(nnkCall, bindSym"mixPrevious", game, entity), resBody)

proc transformChildren(game, entity, n: NimNode): NimNode =
   proc foreignCall(n, game, entity: NimNode): NimNode =
      expectMinLen n, 1
      result = copyNimNode(n)
      result.add n[0]
      result.add game
      result.add entity
      for i in 1 ..< n.len: result.add n[i]

   if n.kind in nnkCallKinds and n[0].kind == nnkIdent:
      case $n[0]
      of "blueprint":
         result = newTree(nnkStmtList)
         let temp = genSym(nskTemp)
         transformBlueprint(result, game, temp, entity, n, 1)
         return
      of "entity":
         expectLen n, 2
         let temp = genSym(nskTemp)
         result = newLetStmt(temp, foreignCall(n[1], game, entity))
         return

   result = copyNimNode(n)
   for i in 0 ..< n.len:
      result.add transformChildren(game, entity, n[i])

proc blueprintImpl(game, entity, transform, hierarchy, n: NimNode): NimNode =
   proc mixinCall(game, entity, n: NimNode): NimNode =
      expectMinLen n, 1
      result = newCall("mix" & n[0].strVal, game, entity)
      if n.kind == nnkObjConstr:
         for i in 1 ..< n.len:
            result.add newTree(nnkExprEqExpr, n[i][0], n[i][1])

   proc handleStmtList(result, game, entity, n: NimNode) =
      for a in n:
         if a.kind in {nnkStmtList, nnkStmtListExpr}:
            handleStmtList(result, game, entity, a)
         else:
            result.add mixinCall(game, entity, a)

   if n.kind in nnkCallKinds and n[0].kind == nnkIdent:
      case $n[0]
      of "with":
         result = newStmtList()
         if n.len == 2 and n[1].kind in {nnkStmtList, nnkStmtListExpr}:
            handleStmtList(result, game, entity, n[1])
         else:
            for i in 1 ..< n.len:
               result.add mixinCall(game, entity, n[i])
         return
      of "children":
         result = transformChildren(game, entity, n[1]) # fix
         return
   elif n.kind in {nnkAsgn, nnkExprEqExpr} and n[0].kind == nnkIdent:
      case $n[0]
      of "translation", "rotation", "scale":
         transform.add newTree(nnkExprEqExpr, n[0], n[1])
         result = newTree(nnkNone) # tmps here? / copy the ast
         return
      of "parent":
         hierarchy.add newTree(nnkExprEqExpr, n[0], n[1])
         result = newTree(nnkNone)
         return

   result = copyNimNode(n)
   for i in 0 ..< n.len:
      let t = blueprintImpl(game, entity, transform, hierarchy, n[i])
      if t.kind != nnkNone: result.add t

macro addBlueprint*(game: Game, body: varargs[untyped]): Entity =
   result = newTree(nnkStmtListExpr)
   let entity = genSym(nskLet, "blueprintResult")
   transformBlueprint(result, game, entity, newTree(nnkNone), body, 0)
   result.add entity
   echo result.repr

var game: Game
let a = game.addBlueprint(translation = Vec2(x: 1.0, y: 2.0), parent = game.camera, with Fade(step: 0.5))

discard game.addBlueprint(translation = Vec2(x: 1.0, y: 1.0), parent = game.camera,
      with(Fade(step: 0.0), ControlBrick()),
      children(blueprint(translation = Vec2(x: 2.0, y: 2.0), rotation = 1.0), entity getBrick(2.0, 2.0, 10, 10)))

proc getBall*(game: var Game, parent = game.camera, x, y: float32): Entity =
   let angle = Pi + rand(1.0) * Pi
   result = game.createEntityWith: # no hierarchy
      Transform2d(translation: Vec2(x: x, y: y))
      Hierarchy(parent: parent)
      Collide(size: Vec2(x: 20.0, y: 20.0))
      ControlBall()
      Draw2d(width: 20, height: 20, color: [0'u8, 255, 0, 255])
      Move(direction: Vec2(x: cos(angle), y: sin(angle)), speed: 600.0)
