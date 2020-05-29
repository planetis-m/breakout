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

   Component* {.inheritable.} = object
   Collide* = object of Component
   Fade* = object of Component
   Transform2d* = object of Component
   Shake* = object of Component
   Move* = object of Component
   ControlBall* = object of Component

   Game* = object
      world*: seq[set[HasComponent]]
      camera*: Entity

      components*: array[HasComponent, seq[Component]]

var game = Game(
   world: newSeq[set[HasComponent]](MaxEntities),
   components: [
      HasCollide: newSeq[Collide](MaxEntities),
      HasFade: newSeq[Fade](MaxEntities),
      HasTransform2d: newSeq[Transform2d](MaxEntities),
      HasShake: newSeq[Shake](MaxEntities),
      HasMove: newSeq[Move](MaxEntities),
      HasControlBall: newSeq[ControlBall](MaxEntities)])
