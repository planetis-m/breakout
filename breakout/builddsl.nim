import std/macros, gametypes, utils, mixins
export mixins

const
  StmtContext = ["[]=", "add", "inc", "echo", "dec", "!"]

proc getName(n: NimNode): string =
  case n.kind
  of nnkStrLit..nnkTripleStrLit, nnkIdent, nnkSym:
    result = n.strVal
  of nnkDotExpr:
    result = getName(n[1])
  of nnkAccQuoted, nnkOpenSymChoice, nnkClosedSymChoice:
    result = getName(n[0])
  else:
    expectKind(n, nnkIdent)

proc tBlueprint(n, world, tmpContext: NimNode, isMixin: bool): NimNode =
  proc foreignCall(n, world, tmpContext: NimNode): NimNode =
    expectMinLen n, 1
    result = copyNimNode(n)
    result.add n[0]
    result.add world
    result.add tmpContext
    for i in 1 ..< n.len: result.add n[i]

  case n.kind
  of nnkLiterals, nnkIdent, nnkSym, nnkDotExpr, nnkBracketExpr:
    result = n
  of nnkForStmt, nnkIfExpr, nnkElifExpr, nnkElseExpr,
      nnkOfBranch, nnkElifBranch, nnkExceptBranch, nnkElse,
      nnkConstDef, nnkWhileStmt, nnkIdentDefs, nnkVarTuple:
    # recurse for the last son:
    result = copyNimTree(n)
    let len = n.len
    if len > 0:
      result[len-1] = tBlueprint(result[len-1], world, tmpContext, isMixin)
  of nnkStmtList, nnkStmtListExpr, nnkWhenStmt, nnkIfStmt, nnkTryStmt,
      nnkFinally, nnkBlockStmt, nnkBlockExpr:
    # recurse for every child:
    result = copyNimNode(n)
    for x in n:
      result.add tBlueprint(x, world, tmpContext, isMixin)
  of nnkCaseStmt:
    # recurse for children, but don't add call for case ident
    result = copyNimNode(n)
    result.add n[0]
    for i in 1 ..< n.len:
      result.add tBlueprint(n[i], world, tmpContext, isMixin)
  of nnkProcDef, nnkVarSection, nnkLetSection, nnkConstSection:
    result = n
  of nnkObjConstr:
    if tmpContext != nil and isMixin:
      result = newCall("mix" & $n[0], world, tmpContext)
      for i in 1 ..< n.len:
        result.add newTree(nnkExprEqExpr, n[i][0], n[i][1])
    else:
      result = n
  of nnkCallKinds:
    let op = getName(n[0])
    if eqIdent(op, "blueprint"):
      let tmp = genSym(nskLet, "tmp")
      let call = newTree(nnkCall, bindSym"createEntity", world)
      result = newTree(
        if tmpContext == nil: nnkStmtListExpr else: nnkStmtList,
        newLetStmt(tmp, call))
      for i in 1 ..< n.len:
        let x = n[i]
        if x.kind == nnkExprEqExpr:
          let key = getName(x[0])
          if eqIdent(key, "id"):
            result.add newLetStmt(x[1], tmp)
          else: error("Unsupported attribute: " & key, x)
        else:
          result.add tBlueprint(x, world, tmp, false)
      if tmpContext == nil:
        result.add tmp
      else: discard
    elif eqIdent(op, "with"):
      assert tmpContext != nil
      result = newTree(nnkStmtList)
      for i in 1 ..< n.len:
        result.add tBlueprint(n[i], world, tmpContext, true)
    elif eqIdent(op, "children"):
      assert tmpContext != nil
      result = tBlueprint(n[1], world, tmpContext, false)
    elif tmpContext != nil and op notin StmtContext:
      if isMixin:
        expectLen(n, 1)
        result = newCall("mix" & $n[0], world, tmpContext)
      else:
        result = newTree(nnkDiscardStmt, foreignCall(n, world, tmpContext))
    elif op == "!" and n.len == 2:
      result = n[1]
    else:
      result = n
  else:
    result = n

macro build*(world: World, children: untyped): untyped =
  let kids = newProc(procType=nnkDo, body=children)
  expectKind kids, nnkDo
  result = tBlueprint(body(kids), world, nil, false)
  when defined(debugBlueprint):
    echo repr(result)

macro build*(world: World, node, children: untyped): untyped =
  let kids = newProc(procType=nnkDo, body=children)
  expectKind kids, nnkDo
  var call: NimNode
  if node.kind in nnkCallKinds:
    call = node
  else:
    call = newCall(node)
  call.add body(kids)
  result = tBlueprint(call, world, nil, false)
  when defined(debugBlueprint):
    echo repr(result)
