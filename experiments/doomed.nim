const
   MaxEntities* = 10_000

type
   Has* {.pure.} = enum
      Collide,
      Fade,
      Transform2d,
      Shake,
      Move,
      ControlBall

   Entity* = int32

   Collide* = object
   Transform2d* = object
   Fade* = object
   Move* = object
   Shake* = object
   ControlBall* = object

   Game* = object
      world*: seq[set[Has]]
      camera*: Entity

      collide*: seq[Collide]
      shake*: seq[Shake]
      move*: seq[Move]
      fade*: seq[Fade]
      transform*: seq[Transform2d]
      controlBall*: seq[ControlBall]

iterator view[A, B](game: Game; a: seq[A], b: seq[B]): (A, B) =
   const Query = {Has.A, Has.B}
   for i in 0 ..< MaxEntities:
      if game.world[i] * Query == Query:
         yield (a[i], b[i])

iterator view[A, B, C](game: Game; a: seq[A], b: seq[B], c: seq[C]): (A, B, C) =
   const Query = {Has.A, Has.B, Has.C}
   for i in 0 ..< MaxEntities:
      if game.world[i] * Query == Query:
         yield (a[i], b[i], c[i])

proc main =
   var game = Game(
      world: newSeq[set[Has]](MaxEntities),
      transform: newSeq[Transform2d](MaxEntities),
      move: newSeq[Move](MaxEntities),
      fade: newSeq[Fade](MaxEntities),
      collide: newSeq[Collide](MaxEntities),
      controlBall: newSeq[ControlBall](MaxEntities))

   game.world[0] = {Has.Transform2d, Has.Move, Has.ControlBall, Has.Collide}

   for transform, collider in view(game, game.transform, game.collide):
      echo collider

# not working
