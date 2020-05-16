import macros, vmath, math, random

type
   Game* = object

proc createEntity*(self: var Game): int = discard

proc mixControlBall(game: var Game, entity: int, angle = Pi * 0.33) = discard
proc mixControlBrick(game: var Game, entity: int) = discard
proc mixTransform2d(game: var Game, entity: int, translation = vec2(0, 0),
      rotation = 0.0, scale = vec2(1, 1)) = discard
proc mixHierarchy(self: var Game, entity: int, parent = -1) = discard
proc mixPrevious(self: var Game, entity: int) = discard

proc blueprintImpl(game, entity, parent, transform, hierarchy, n: NimNode): NimNode

proc transformBlueprint(result, game, entity, parent, n: NimNode) =
   result.add newLetStmt(entity, newTree(nnkCall, bindSym"createEntity", game))

   let
      transform = newTree(nnkCall, bindSym"mixTransform2d", game, entity)
      hierarchy = newTree(nnkCall, bindSym"mixHierarchy", game, entity)
      resBody = blueprintImpl(game, entity, parent, transform, hierarchy, n)

   resBody.add(transform, hierarchy,
         newTree(nnkCall, bindSym"mixPrevious", game, entity))

   result.add resBody

proc transformChildren(game, entity, parent, n: NimNode): NimNode =
   if n.kind in nnkCallKinds and n[0].kind == nnkIdent:
      case $n[0]
      of "blueprint":
         expectLen n, 2
         result = newTree(nnkStmtList)
         let temp = genSym(nskTemp)

         transformBlueprint(result, game, temp, entity, n[1])
         return
      of "entity":
         expectLen n, 2

         let temp = genSym(nskTemp)
         result = newStmtList(newLetStmt(temp, n[1]),
               newTree(nnkCall, bindSym"mixHierarchy", game, temp, entity))
         return

   result = copyNimNode(n)
   for i in 0 ..< n.len:
      result.add transformChildren(game, entity, parent, n[i])

proc blueprintImpl(game, entity, parent, transform, hierarchy, n: NimNode): NimNode =
   expectMinLen n, 1

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
         expectLen n, 2
         result = transformChildren(game, entity, parent, n[1])
         return
   elif n.kind == nnkAsgn and n[0].kind == nnkIdent:
      case $n[0]
      of "translation", "rotation", "scale":
         transform.add newTree(nnkExprEqExpr, n[0], n[1])
         result = newTree(nnkNone)
         return
      of "parent":
         hierarchy.add newTree(nnkExprEqExpr, n[0], n[1])
         result = newTree(nnkNone)
         return

   result = copyNimNode(n)
   for i in 0 ..< n.len:
      let t = blueprintImpl(game, entity, parent, transform, hierarchy, n[i])
      if t.kind != nnkNone: result.add t

macro addBlueprint(game: Game, body: untyped): int =
   result = newTree(nnkStmtListExpr)
   let entity = genSym(nskLet, "blueprintResult")
   transformBlueprint(result, game, entity, newTree(nnkNone), body)
   result.add entity
   echo result.repr

proc getPaddle(game: var Game, parent = -1, x, y: float32): int =
   let angle = Pi + rand(1.0) * Pi
   result = game.addBlueprint:
      translation = Vec2(x: x, y: y)
      rotation = 2.0'f32
      scale = Vec2(x: 0.5, y: 0.5)
      parent = parent
      with:
         ControlBall(angle: angle)
         ControlBrick()
      children:
         blueprint:
            with ControlBall(angle: angle)

proc getPaddle2(game: var Game, parent = -1, x, y: float32): int =
   let angle = Pi + rand(1.0) * Pi
   result = block:
      let entity = createEntity(game)
      mixControlBall(game, entity, angle)
      mixControlBrick(game, entity)
      mixTransform2d(game, entity, translation = Vec2(x: x, y: y),
            rotation = 2.0'f32, scale = Vec2(x: 0.5, y: 0.5))
      #mixHierarchy(game, entity, parent)
      # children
      let temp = createEntity(game)
      mixControlBall(game, temp, angle)
      mixTransform2d(game, temp)
      #mixHierarchy(game, temp, entity)
      entity
