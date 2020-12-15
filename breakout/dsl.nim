import macros, gametypes, utils, mixins
export mixins

proc blueprintImpl(world, entity, parent, n: NimNode): NimNode

proc transformBlueprint(result, world, entity, parent, n: NimNode) =
  let resBody = blueprintImpl(world, entity, parent, n)
  result.add newLetStmt(entity, newTree(nnkCall, bindSym"createEntity", world))
  result.add resBody

proc transformChildren(world, entity, parent, n: NimNode): NimNode =
  proc foreignCall(n, world, entity: NimNode): NimNode =
    expectMinLen n, 1
    result = copyNimNode(n)
    result.add n[0]
    result.add world
    result.add entity
    for i in 1 ..< n.len: result.add n[i]
  if n.kind in nnkCallKinds and n[0].kind == nnkIdent:
    case $n[0]
    of "blueprint":
      expectLen n, 2
      result = newTree(nnkStmtList)
      let temp = genSym(nskTemp)
      transformBlueprint(result, world, temp, entity, n[1])
      return
    of "entity":
      expectLen n, 2
      let temp = genSym(nskTemp)
      result = newLetStmt(temp, foreignCall(n[1], world, entity))
      return
  result = copyNimNode(n)
  for i in 0 ..< n.len:
    result.add transformChildren(world, entity, parent, n[i])

proc blueprintImpl(world, entity, parent, n: NimNode): NimNode =
  proc mixinCall(world, entity, n: NimNode): NimNode =
    expectMinLen n, 1
    result = newCall("mix" & $n[0], world, entity)
    if n.kind == nnkObjConstr:
      for i in 1 ..< n.len:
        result.add newTree(nnkExprEqExpr, n[i][0], n[i][1])
  proc handleStmtList(result, world, entity, n: NimNode) =
    for a in n:
      if a.kind in {nnkStmtList, nnkStmtListExpr}:
        handleStmtList(result, world, entity, a)
      else:
        result.add mixinCall(world, entity, a)
  if n.kind in nnkCallKinds and n[0].kind == nnkIdent:
    case $n[0]
    of "with":
      result = newStmtList()
      if n.len == 2 and n[1].kind in {nnkStmtList, nnkStmtListExpr}:
        handleStmtList(result, world, entity, n[1])
      else:
        for i in 1 ..< n.len:
          result.add mixinCall(world, entity, n[i])
      return
    of "children":
      expectLen n, 2
      result = transformChildren(world, entity, parent, n[1])
      return
  result = copyNimNode(n)
  for i in 0 ..< n.len:
    result.add blueprintImpl(world, entity, parent, n[i])

macro addBlueprint*(world: World, body: untyped): Entity =
  result = newTree(nnkStmtListExpr)
  let entity = genSym(nskLet, "blueprintResult")
  transformBlueprint(result, world, entity, newTree(nnkNone), body)
  result.add entity

macro addBlueprint*(world: World, entity, body: untyped): Entity =
  result = newTree(nnkStmtListExpr)
  transformBlueprint(result, world, entity, newTree(nnkNone), body)
  result.add entity
