import ".."/[dsl, game_types, vmath]

var game = Game()
let a = addBlueprint(game, translation = Vec2(x: 1.0, y: 2.0),
      parent = game.camera, with(Fade(step: 0.0), ControlBrick()),
      children(blueprint(translation = Vec2(x: 1.0, y: 2.0)), entity getBrick(2.0, 2.0, 10, 10)))
let b = game.addBlueprint(translation = Vec2(x: 1.0, y: 2.0), with Fade(step: 0.5))

proc transformBlueprint(result, game, entity, parent, n: NimNode) =
   proc handleStmtList(result, game, entity, transform, parent, n: NimNode) =
      for a in n:
         if a.kind notin {nnkStmtList, nnkStmtListExpr}:
            handleStmtList(result, game, entity, transform, parent, a)
         else:
            transformBlueprint(result, game, entity, transform, parent, a)

   let parent = newTree(nnkNone)
   let transform = newTree(nnkCall, bindSym"mixTransform2d", game, entity)
   expectKind body, nnkArgList
   if body.len == 1 and body[0].kind in {nnkStmtList, nnkStmtListExpr}:
      handleStmtList(result, game, entity, transform, parent, body)
   else:
      for n in body:
         transformBlueprint(result, game, entity, transform, parent, n)
   let hierarchy = newTree(nnkCall, bindSym"mixHierarchy", game, entity)
   let resBody = blueprintImpl(game, entity, parent, transform, hierarchy, n)

   if parent.kind != nnkNone and hierarchy.len == 3: hierarchy.add parent
   result.add(newLetStmt(entity, newTree(nnkCall, bindSym"createEntity", game)),
         hierarchy, newTree(nnkCall, bindSym"mixPrevious", game, entity),
         resBody)

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

macro addBlueprint*(game: Game, body: varargs[untyped]): Entity =
   result = newTree(nnkStmtListExpr)
   let entity = genSym(nskLet, "blueprintResult")

   result.add entity
   echo result.repr
