import macros, game_types, registry, utils, mixins
export mixins

proc blueprintImpl(game, entity, transform, hierarchy, n: NimNode): NimNode

proc transformBlueprint(result, game, entity, parent, n: NimNode) =
   let transform = newCall(bindSym"mixTransform2d", game, entity)
   let hierarchy = newCall(bindSym"mixHierarchy", game, entity)
   let resBody = blueprintImpl(game, entity, transform, hierarchy, n)

   if parent.kind != nnkNone and hierarchy.len == 3: hierarchy.add parent
   result.add(newLetStmt(entity, newCall(bindSym"createEntity", game)),
         transform, hierarchy, newCall(bindSym"mixDirty", game, entity),
         newCall(bindSym"mixNewlyCreated", game, entity), resBody)

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
         expectLen n, 2
         result = newTree(nnkStmtList)
         let temp = genSym(nskTemp)
         transformBlueprint(result, game, temp, entity, n[1])
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
         expectLen n, 2
         result = transformChildren(game, entity, n[1])
         return
   elif n.kind == nnkAsgn and n[0].kind == nnkIdent:
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

macro addBlueprint*(game: Game, body: untyped): Entity =
   result = newTree(nnkStmtListExpr)
   let entity = genSym(nskLet, "blueprintResult")
   transformBlueprint(result, game, entity, newTree(nnkNone), body)
   result.add entity
