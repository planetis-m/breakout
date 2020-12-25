import std/[macros, parsejson, strutils], gametypes

template readTuple(parser, hasSym, body) =
  eat(parser, tkBracketLe)
  var hasSym: HasComponent
  initFromJson(hasSym, parser)
  body
  eat(parser, tkBracketRi)

template raiseWrongKey(parser) =
  raiseParseErr(parser, "valid proc argument")

template caseANormalized: untyped =
  nnkCaseStmt.newTree(newCall(bindSym"nimIdentNormalize", newDotExpr(parser, ident"a")))

template getFieldValue(parser, varSym) =
  discard getTok(parser)
  eat(parser, tkColon)
  initFromJson(varSym, parser)

template readFields(parser, varSection, body) =
  eat(p, tkComma)
  eat(parser, tkCurlyLe)
  varSection
  while parser.tok != tkCurlyRi:
    if parser.tok != tkString:
      raiseParseErr(parser, "string literal as key")
    body
    if parser.tok != tkComma: break
    discard getTok(parser)
  eat(parser, tkCurlyRi)

macro dispatch*(world: World; entity: Entity; parser: JsonParser, body: untyped): untyped =
  let has = genSym(nskVar, "has")
  let caseHas = nnkCaseStmt.newTree(has)
  for n in body:
    expectKind(n, nnkProcDef)
    let inner = newStmtList()
    let comp = substr($n.name, len("on"))
    let mixCall = newCall("mix" & comp, world, entity)
    if n.params.len > 1:
      let varSection = newNimNode(nnkVarSection)
      let caseField = caseANormalized()
      for i in 1..<n.params.len:
        let param = n.params[i]
        expectKind(param, nnkIdentDefs)
        varSection.add param
        for j in 0 ..< param.len-2:
          mixCall.add newTree(nnkExprEqExpr, param[j], param[j])
          caseField.add nnkOfBranch.newTree(newLit(nimIdentNormalize($param[j])),
              getAst(getFieldValue(parser, param[j])))
      caseField.add nnkElse.newTree(getAst(raiseWrongKey(parser)))
      inner.add getAst(readFields(parser, varSection, caseField))
    inner.add mixCall
    caseHas.add nnkOfBranch.newTree(ident("Has" & comp), inner)
  caseHas.add nnkElse.newTree(newTree(nnkDiscardStmt, newNimNode(nnkEmpty)))
  result = getAst(readTuple(parser, has, caseHas))
