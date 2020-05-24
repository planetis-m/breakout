import macros

type
   HasComponent* = enum
      HasCollide,
      HasControlBall,
      HasControlBrick,
      HasControlPaddle,
      HasDraw2d,
      HasFade,
      HasHierarchy,
      HasMove,
      HasPrevious,
      HasShake,
      HasTransform2d

proc stepSystems(): seq[(string, int)] =
   result = @{
      "sysHandleInput": 0,
      "sysControlBall": 0,
      "sysControlBrick": 0,
      "sysShake": 1,
      "sysControlPaddle": 1,
      "sysFade": 2,
      "sysMove": 3,
      "sysTransform2d": 4,
      "sysCollide": 5}

const steps = stepSystems()

macro runInParallel(this: static set[HasComponent]): untyped =
   echo HasControlBall in this
   echo steps
   result = newStmtList()

runInParallel({HasControlPaddle, HasHierarchy})
