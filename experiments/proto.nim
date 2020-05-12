import macros, vmath, math, random

const
   MaxEntities* = 10000

type
   HasComponent* = enum
      HasControlBall,
      HasControlBrick,
      HasTransform2d,
   ControlBall* = object
      direction*: Vec2
   Transform2d* = object
      world*: Mat2d      # Matrix relative to the world
      self*: Mat2d       # World to self matrix
      translation*: Vec2 # local translation relative to the parent
      rotation*: float32 # local rotation relative to the parent
      scale*: Vec2       # local scale relative to the parent
      parent*: int
      children*: seq[int]
      dirty*: bool
   Game* = object
      world*: seq[set[HasComponent]]
      camera*: int
      controlBall*: seq[ControlBall]
      transform*: seq[Transform2d]

proc createEntity*(self: var Game): int =
   for i in 0 ..< MaxEntities:
      if self.world[i] == {}:
         return i
   raise newException(ValueError, "No more entities available!")

proc mixControlBall(game: var Game, entity: int, angle = Pi * 0.33) =
   game.world[entity].incl HasControlBall
   game.controlBall[entity] = ControlBall(direction: vec2(cos(angle), sin(angle)))
proc mixControlBrick(game: var Game, entity: int) =
   game.world[entity].incl HasControlBrick
proc mixTransform2d(game: var Game, entity: int, translation = vec2(0, 0),
      rotation = 0.0, scale = vec2(1, 1)) =
   game.world[entity].incl HasTransform2d
   game.transform[entity] = Transform2D(world: mat2d(), self: mat2d(),
         translation: translation, rotation: rotation, scale: scale, dirty: true)

proc transformChildren(game, n: NimNode): NimNode =
   if n.kind in nnkCallKinds and n[0].kind == nnkIdent:
      case $n[0]
      of "blueprint":
         let res = genSym(nskLet, "blueprintResult")
         let transParam = newTree(nnkCall, bindSym"mixTransform2d", game)
         let resBody = blueprintImpl(game, res, entity, transParam, body)
         resBody.add transParam
         result = nnkStmtList.newTree(newLetStmt(res, newTree(nnkCall,
            bindSym"createEntity", game)), resBody)
   else:
      result = copyNimNode(n)
      for i in 0 ..< n.len:
         result.add transformChildren(game, parent, n[i])

proc blueprintImpl(game, entity, parent, n: NimNode): NimNode =
   expectKind n, nnkStmtList
   expectMinLen n, 1

   if n.kind in nnkCallKinds and n[0].kind == nnkIdent:
      case $n[0]
      of "with":
         expectLen n, 2
         result = nnkStmtList.newTree()
         for n1 in n:
            var params: seq[NimNode]
            for i in 1 ..< n1.len:
               n1[i].expectKind nnkColonExpr
               params.add newAssignment n1[i][0], n1[i][1]
            result.add newCall(bindSym("mix" & n1[0].strVal), params)
      of "children":
         expectLen n, 2
         result = transformChildren(game, n[1])
   elif n.kind == nnkAsgn:
      result[1].add n
   elif n.kind == nnkStmtList, nnkStmtListExpr, nnkBlockStmt, nnkBlockExpr, nnkWhileStmt,
         nnkForStmt, nnkElifBranch, nnkExceptBranch, nnkOfBranch, nnkElse, nnkElifExpr,
         nnkIfExpr, nnkIfStmt, nnkTryStmt, nnkCaseStmt:
      result = copyNimNode(n)
      for i in ord(n.kind == nnkCaseStmt) ..< n.len:
         result.add blueprintImpl(game, parent, n[i])
   else:
      result = copyNimTree(n)

macro blueprint(game: Game, body: untyped): int =
   let res = genSym(nskLet, "blueprintResult")
   let transParam = newTree(nnkCall, bindSym"mixTransform2d", game)
   let resBody = blueprintImpl(game, res, newTree(nnkNone), transParam, body)
   resBody.add transParam
   result = newTree(nnkStmtListExpr,
         newLetStmt(res, newTree(nnkCall, bindSym"createEntity", game)), resBody, res)
   echo body.repr
   echo result.repr

proc getPaddle(game: var Game, parent = game.camera, x, y: float32): int =
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

proc getPaddle2(game: var Game, parent = game.camera, x, y: float32): int =
   let angle = Pi + rand(1.0) * Pi
   result = block:
      let entity = createEntity(game)
      mixControlBall(game, entity, angle)
      mixControlBrick(game, entity)
      mixTransform2d(game, entity, translation = Vec2(x: x, y: y),
            rotation = 2.0'f32, scale = Vec2(x: 0.5, y: 0.5))
      mixHierarchy(game, entity, parent)
      # children
      let temp = createEntity(game)
      mixControlBall(game, temp, angle)
      mixTransform2d(game, temp)
      mixHierarchy(game, temp, entity)
      entity
