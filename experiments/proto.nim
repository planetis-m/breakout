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

proc transformBlueprint(result, n: NimNode): NimNode =
   let entity = genSym(nskLet, "blueprintResult")
   result.add newLetStmt(entity, newTree(nnkCall, bindSym"createEntity", game)
   let transParam = newTree(nnkCall, bindSym"mixTransform2d", game, entity)
   let resBody = blueprintImpl(game, entity, newTree(nnkNone), transParam, body)
   resBody.add transParam
   resBody.add newTree(nnkCall, bindSym"mixHierarchy", game, entity, b.parent)
   resBody.add newTree(nnkCall, bindSym"mixPrevious", game, entity)

   result.add resBody
   result.add entity

proc transformChildren(game, n: NimNode): NimNode =
   if n.kind in nnkCallKinds and n[0].kind == nnkIdent:
      case $n[0]
      of "blueprint":
         expectLen n, 2
         result = newTree(nnkStmtList)

         transformBlueprint(result, n[1])
         return
      of "entity":
         expectLen n, 2
         result = newTree(nnkStmtList)
         return

   result = copyNimNode(n)
   for i in 0 ..< n.len:
      result.add transformChildren(game, parent, n[i])

proc blueprintImpl(game, entity, parent, n: NimNode): NimNode =
   expectKind n, nnkStmtList
   expectMinLen n, 1

   proc mixinCall(n: NimNode): NimNode =
      expectMinLen n, 1
      result = newCall(bindSym("mix" & n[0].strVal))
      if n.kind == nnkObjConstr:
         for i in 1 ..< n.len:
            result.add newTree(nnkExprEqExpr, n[i][0], n[i][1])

   proc handleStmtList(result, n: NimNode): NimNode =
      for a in n:
         if a.kind in {nnkStmtList, nnkStmtListExpr}:
            handleStmtList(result, a)
         else:
            result.add mixinCall(call)

   if n.kind in nnkCallKinds and n[0].kind == nnkIdent:
      case $n[0]
      of "with":
         result = newStmtList()
         if n.len == 2 and n[1].kind in {nnkStmtList, nnkStmtListExpr}:
            handleStmtList(result, n[1])
         else:
            for i in 1 ..< n.len:
               result.add mixinCall(n[i])
         return
      of "children":
         expectLen n, 2
         result = transformChildren(game, n[1])
         return
   elif n.kind == nnkAsgn and n[0].kind == nnkIdent:
      case $n[0]
      of "translation", "rotation", "scale":
         transform.add newTree(nnkExprEqExpr, n[0], n[1])
         return
      of "parent":
         hierarchy.add newTree(nnkExprEqExpr, n[0], n[1])
         return

   result = copyNimNode(n)
   for i in 0 ..< n.len:
      result.add blueprintImpl(game, parent, n[i])

macro addBlueprint(game: Game, body: untyped): int =
   result = newTree(nnkStmtListExpr)
   transformBlueprint(result, body)
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
