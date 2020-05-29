import macros

const
   MaxEntities* = 10_000

type
   HasComponent* = enum
      HasCollide,
      HasFade,
      HasTransform2d,
      HasShake,
      HasMove,
      HasControlBall

   Entity* = int32

   Collide* = object
   Transform2d* = object
   Fade* = object
   Move* = object
   Shake* = object
   ControlBall* = object

   Game* = object
      world*: seq[set[HasComponent]]
      camera*: Entity

      collide*: seq[Collide]
      shake*: seq[Shake]
      move*: seq[Move]
      fade*: seq[Fade]
      transform*: seq[Transform2d]
      controlBall*: seq[ControlBall]

iterator view(game: var Game; t: typedesc[Transform2d], k: typedesc[Collide]): (Transform2d, Collide) =
   const Query = {HasTransform2d, HasCollide}
   for i in 0 ..< MaxEntities:
      if game.world[i] * Query != {}:
         yield (game.transform[i], game.collide[i])
iterator view(game: var Game; t: typedesc[Fade], k: typedesc[Collide]): (Fade, Collide) =
   const Query = {HasFade, HasCollide}
   for i in 0 ..< MaxEntities:
      if game.world[i] * Query != {}:
         yield (game.fade[i], game.collide[i])
var game = Game(
   world: newSeq[set[HasComponent]](MaxEntities),
   transform: newSeq[Transform2d](MaxEntities),
   move: newSeq[Move](MaxEntities),
   fade: newSeq[Fade](MaxEntities),
   collide: newSeq[Collide](MaxEntities),
   controlBall: newSeq[ControlBall](MaxEntities))
game.world[0] = {HasTransform2d, HasMove, HasControlBall, HasCollide}

for transform, collider in view(game, Transform2d, Collide):
   echo collider

#[
for transform, collider in view[Transform2d, Collide](game):

# For loop
for transform, collider in components(game, Transform2d, Collide):
for transform, collider in components(game, (Transform2d, Collide)):
for transform, collider in view[Transform2d, Collide](game):
   body

const Query = {HasTransform2d, HasCollide}
for i in 0 ..< MaxEntities:
   if game.world[i] * Query != {}:
      template transform: untyped = game.transform[i]
      template collider: untyped = game.collide[i]
      body

# Procs
proc update(game: var Game, entity: Entity) {.components({fade: Fade, collide: Collide}).} =
proc update(game: var Game, entity: Entity) {.components(fade = Fade, collide = Collide).} =
proc update(game: var Game, entity: Entity) {.components(Fade, Collide).} =
   body

proc update(game: var Game, entity: Entity) =
   template collide: untyped = game.collide[entity]
   template fade: untyped = game.fade[entity]
   body

# Singleton Component
if component(game, game.camera, {cameraShake: Shake}):
if component(game, game.camera, cameraShake = Shake):
   body

if (template cameraShake: untyped = game.shake[game.camera];
      HasShake in game.world[game.camera]):
   body

OR

for transform2d, collide in components(game):
   body
proc update(game: var Game, entity: Entity) {.components(fade, collide).} =
   body
if component(game, game.camera, shake):
   body
]#

# {.experimental: "forLoopMacros".}
#
# macro components*(x: ForLoopStmt): untyped =
#    expectKind x, nnkForStmt
#    result = newStmtList()
#
# macro components(x: varargs[untyped]): untyped =
#    echo x.treeRepr
#    expectKind x, nnkProcDef
#    template alias(name, index) =
#       template name: untyped = game.world[index]
#    let params = params(x)
#    expectKind(params[2], nnkIdentDefs)
#    let theIndex = params[2][0]
#    if not eqIdent(theIndex[^2], "Entity"): error("Expected Entity/ies after after the Game object")
#    x.body.insert(0, getAst(alias(ident"entity", theIndex)))
#    result = x
#    echo result.repr
#
# proc update(game: var Game, entity: Entity) {.components({fade: Fade}).} =
# #    template fade: untyped = game.fade[entity]
#
#    echo fade
#
# var game: Game
# update(game, 0)

#[
queries(game, entity):
   hit:
      has = {HasCollide}
   context:
      has = {HasTransform2d, HasMove, HasControlBall}
      mandatory = true

template context(game, tmp1, tmp2, tmp3, body: untyped): untyped =
   const Query = {HasTransform2d, HasMove, HasControlBall}
   for i in 0 ..< MaxEntities:
      if game.world[i] * Query != {}:
         template tmp1: untyped = game.transform[i]
         template tmp2: untyped = game.move[i]
         template tmp3: untyped = game.controlBall[i]
         body

template hit(tmp1, body: untyped): untyped =
   template tmp1: untyped = game.collide[entity]

proc sysControlBall(game: var Game) {.context(transform, move, control).} =
   echo transform

   hit(collide):
      echo collide

OR

system(sysControlBall):
   hit:
      has = {HasCollide}
   context:
      has = {HasTransform2d, HasMove, HasControlBall}
      mandatory = true

   context(transform, move, control)
   echo transform

template context(tmp1, tmp2, tmp3: untyped): untyped =
   template tmp1: untyped = game.transform[i]
   template tmp2: untyped = game.move[i]
   template tmp3: untyped = game.controlBall[i]

proc sysControlBall(game: var Game) =
   const Query = {HasTransform2d, HasMove, HasControlBall}
   for i in 0 ..< MaxEntities:
      if game.world[i] * Query != {}:
         context(transform, move, control)
         echo transform

OR

queries(game, i):
   hit:
      has = {HasCollide}
   context:
      has = {HasTransform2d, HasMove, HasControlBall}
      mandatory = true

{.experimental: "forLoopMacros".}

macro context*(x: ForLoopStmt): untyped =
   result = newStmtList()

template hit(tmp1: untyped): untyped =
   (template tmp1: untyped = game.collide[entity]; HasCollide in game.world[entity]))

proc sysControlBall(game: var Game) =
   for (transform, move, control) in context(game):
      echo transform

      if hit(collide):
         echo collide

proc sysControlBall(game: var Game) =
   const Query = {HasTransform2d, HasMove, HasControlBall}
   for i in 0 ..< MaxEntities:
      if game.world[i] * Query != {}:
         template transform: untyped = game.transform[i]
         template move: untyped = game.move[i]
         template collide: untyped = game.controlBall[i]
         echo transform

         if hit(collide):
            echo collide

OR
# queries(game, i):
#    hit:
#       has = {HasCollide}
#    update:
#       has = {HasTransform2d, HasMove, HasControlBall}
#       mandatory = true

template hit(tmp1, body: untyped): untyped =
   template tmp1: untyped = game.collide[entity]

template update(tmp1, tmp2, tmp3, body: untyped): untyped =
   proc update(game: var Game) =
      const Query = {HasTransform2d, HasMove, HasControlBall}
      for i in 0 ..< MaxEntities:
         if game.world[i] * Query != {}:
            template tmp1: untyped = game.transform[i]
            template tmp2: untyped = game.move[i]
            template tmp3: untyped = game.controlBall[i]
            body

proc sysControlBall(game: var Game, entity: Entity) {.update(transform, move, control).} =
   echo transform

   hit(collide):
      echo collide

OR

# queries(sysControlBall):
#    hit:
#       components = {HasCollide}
#    context:
#       components = {HasTransform2d, HasMove, HasControlBall}
#       mandatory = true

template hit(tmp1: untyped): untyped =
   (let tmp1 = game.collide[entity]; HasCollide in game.world[entity])

template context(game, entity, tmp1, tmp2, tmp3, body: untyped): untyped =
   proc update(game: var Game, entity: Entity) =
      template tmp1: untyped = game.transform[entity]
      template tmp2: untyped = game.move[entity]
      template tmp3: untyped = game.controlBall[entity]
      body
   proc sysControlBall*(game: var Game) {.inject.} =
      const Query = {HasTransform2d, HasMove, HasControlBall}
      for i in 0 ..< MaxEntities:
         if game.world[i] * Query != {}:
            update(game, Entity(i))

context(game, entity, transform, move, control):
   echo transform
   if hit(collide):
      echo collide
#    echo game.camera # oh no

var game = Game(
   world: newSeq[set[HasComponent]](MaxEntities),
   transform: newSeq[Transform2d](MaxEntities),
   move: newSeq[Move](MaxEntities),
   controlBall: newSeq[ControlBall](MaxEntities))
game.world[0] = {HasTransform2d, HasMove, HasControlBall, HasCollide}
sysControlBall(game)
]#
