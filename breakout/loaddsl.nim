import std/[macros, parsejson, strutils], gametypes, fusion/astdsl

template readTuple(parser, hasSym, body) =
  eat(parser, tkBracketLe)
  var hasSym: HasComponent
  initFromJson(hasSym, parser)
  body
  eat(parser, tkBracketRi)

template raiseWrongKey(parser) =
  raiseParseErr(parser, "valid proc argument")

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
  let caseHas = buildAst(caseStmt(has)):
    for n in body:
      expectKind(n, nnkProcDef)
      let inner = buildAst(stmtList):

        let comp = substr($n.name, "on".len)
        let mixCall = buildAst(call(ident("mix" & comp), world, entity)):
          for i in 1..<n.params.len:
            let param = n.params[i]
            expectKind(param, nnkIdentDefs)
            for j in 0 ..< param.len-2:
              exprEqExpr(param[j], param[j])

        if n.params.len > 1:
          let caseSec = buildAst(caseStmt(call(bindSym"nimIdentNormalize",
              dotExpr(parser, ident"a")))):
            for i in 1..<n.params.len:
              let param = n.params[i]
              for j in 0 ..< param.len-2:
                ofBranch(newLit(nimIdentNormalize($param[j]))):
                  getAst(getFieldValue(parser, param[j]))
            `else`(getAst(raiseWrongKey(parser)))

          let varSec = buildAst(varSection):
            for i in 1..<n.params.len:
              n.params[i]

          getAst(readFields(parser, varSec, caseSec))
        mixCall
      ofBranch(ident("Has" & comp), inner)
    `else`:
      discardStmt(empty())
  result = getAst(readTuple(parser, has, caseHas))
