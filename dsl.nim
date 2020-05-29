import macros, game_types, math, vmath, utils, sparse_set

proc mixCollide*(game: var Game, entity: Entity, size = vec2(0, 0)) =
   game.world[entity].incl HasCollide
   game.collide[entity] = Collide(entity: entity, size: size,
         collision: Collision(entity: invalidId))

proc mixControlBall*(game: var Game, entity: Entity, angle = Pi * 0.33) =
   game.world[entity].incl HasControlBall
   game.controlBall[entity] = ControlBall(direction: vec2(cos(angle), sin(angle)))

proc mixControlBrick*(game: var Game, entity: Entity) =
   game.world[entity].incl HasControlBrick

proc mixControlPaddle*(game: var Game, entity: Entity) =
   game.world[entity].incl HasControlPaddle

proc mixDraw2d*(game: var Game, entity: Entity, width, height = 100'i32,
      color = [255'u8, 0, 255, 255]) =
   game.world[entity].incl HasDraw2d
   game.draw2d[entity] = Draw2d(width: width, height: height, color: color)

proc mixFade*(game: var Game, entity: Entity, step = 0.0) =
   game.world[entity].incl HasFade
   game.fade[entity] = Fade(step: step)

proc mixHierarchy*(game: var Game, entity: Entity, parent = invalidId) =
   game.world[entity].incl HasHierarchy
   game.hierarchy[entity] = Hierarchy(head: invalidId, next: invalidId, parent: parent)
   if parent != invalidId: prepend(game, parent, entity)

proc mixMove*(game: var Game, entity: Entity, direction = vec2(0, 0), speed = 100.0) =
   game.world[entity].incl HasMove
   game.move[entity] = Move(direction: direction, speed: speed)

proc mixPrevious*(game: var Game, entity: Entity) =
   game.world[entity].incl HasPrevious
   #game.previous[entity] = Previous(world: mat2d())

proc mixShake*(game: var Game, entity: Entity, duration = 1.0, strength = 0.0) =
   game.world[entity].incl HasShake
   game.shake[entity] = Shake(duration: duration, strength: strength)

proc mixTransform2d*(game: var Game, entity: Entity, translation = vec2(0, 0),
      rotation = 0.0, scale = vec2(1, 1)) =
   game.world[entity].incl HasTransform2d
   game.transform[entity] = Transform2D(world: mat2d(), self: mat2d(),
         translation: translation, rotation: rotation, scale: scale, dirty: true)

# ---------------
# Blueprint macro
# ---------------

proc blueprintImpl(game, entity, parent, transform, hierarchy, n: NimNode): NimNode

proc transformBlueprint(result, game, entity, parent, n: NimNode) =
   let transform = newTree(nnkCall, bindSym"mixTransform2d", game, entity)
   let hierarchy = newTree(nnkCall, bindSym"mixHierarchy", game, entity)
   let resBody = blueprintImpl(game, entity, parent, transform, hierarchy, n)

   if parent.kind != nnkNone and hierarchy.len == 3: hierarchy.add parent
   resBody.insert(0, hierarchy)
   resBody.add(transform, newTree(nnkCall, bindSym"mixPrevious", game, entity))

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

proc blueprintImpl(game, entity, parent, transform, hierarchy, n: NimNode): NimNode =
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
         result = newTree(nnkNone) # tmps here? / copy the ast
         return
      of "parent":
         hierarchy.add newTree(nnkExprEqExpr, n[0], n[1])
         result = newTree(nnkNone)
         return

   result = copyNimNode(n)
   for i in 0 ..< n.len:
      let t = blueprintImpl(game, entity, parent, transform, hierarchy, n[i])
      if t.kind != nnkNone: result.add t

macro addBlueprint*(game: Game, body: untyped): Entity =
   result = newTree(nnkStmtListExpr)
   let entity = genSym(nskLet, "blueprintResult")
   transformBlueprint(result, game, entity, newTree(nnkNone), body)
   result.add entity
