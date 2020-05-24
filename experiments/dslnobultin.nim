# ---------------
# Blueprint macro
# ---------------

proc blueprintImpl(game, entity, parent, n: NimNode): NimNode

proc transformBlueprint(result, game, entity, parent, n: NimNode) =
   let resBody = blueprintImpl(game, entity, parent, n)
   result.add newLetStmt(entity, newTree(nnkCall, bindSym"createEntity", game))
   result.add resBody

proc transformChildren(game, entity, parent, n: NimNode): NimNode =
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
         expectLen n, 2
         result = newTree(nnkStmtList)
         let temp = genSym(nskTemp)
         transformBlueprint(result, game, temp, entity, n[1])
         return
      of "entity":
         expectLen n, 2
         let temp = genSym(nskTemp)
         result = newStmtList(newLetStmt(temp, foreignCall(n[1], game, entity)))
         return

   result = copyNimNode(n)
   for i in 0 ..< n.len:
      result.add transformChildren(game, entity, parent, n[i])

proc blueprintImpl(game, entity, parent, n: NimNode): NimNode =
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

   result = copyNimNode(n)
   for i in 0 ..< n.len:
      result.add blueprintImpl(game, entity, parent, n[i])

macro addBlueprint*(game: Game, body: untyped): int =
   result = newTree(nnkStmtListExpr)
   let entity = genSym(nskLet, "blueprintResult")
   transformBlueprint(result, game, entity, newTree(nnkNone), body)
   result.add entity
