import cpuinfo

proc update(self: var Game) =
   # The Game engine that consist of these systems
   inParallel(self):
      sysHandleInput(writes = {HasInputState})
      sysControlBall:
         reads = {HasCollide}
         writes = {HasTransform2d, HasMove, HasControlBall, HasShake}
      sysControlBrick(reads = {HasCollide}, writes = {HasFade})
      sysControlPaddle(reads = {HasInputState}, writes = {HasMove})
      sysShake(writes = {HasTransform2d, HasShake, HasClearColor})
      sysFade:
         reads = {HasFade}
         writes = {HasTransform2d, HasDraw2d}
      sysMove(reads = {HasMove}, writes = {HasTransform2d})
      sysTransform2d:
         reads = {HasHierarchy}
         writes = {HasTransform2d, HasPrevious}
      sysCollide(reads = {HasTransform2d}, writes = {HasCollide})

   # sysHandleInput: 0
   # sysControlBall: 0
   # sysControlBrick: 0
   # sysShake: 1
   # sysControlPaddle: 1
   # sysFade: 2
   # sysMove: 3
   # sysTransform2d: 4
   # sysCollide: 5

proc update(self: var Game) =

   const MaxThreads = 4
   var thrs {.global.}: array[MaxThreads, Thread[World]]
   let processors = countProcessors()
   let currentThreads = min(processors, MaxThreads)

   var i = 0
   for sys in items([sysHandleInput, sysControlBall, sysControlBrick]):
      if i >= currentThreads:
         joinThreads(thrs[0..<i])
         i = 0
      createThread(thrs[i], sys, self.world)
      i.inc
   joinThreads(thrs[0..<i])

   var i = 0
   for sys in items([sysControlPaddle, sysShake]):
      if i >= currentThreads:
         joinThreads(thrs[0..<i])
         i = 0
      createThread(thrs[i], sys, self.world)
      i.inc
   joinThreads(thrs[0..<i])

   sysFade(self.world)
   sysMove(self.world)
   sysTransform2d(self.world)
   sysCollide(self.world)

proc update(self: var Game) =

   const MaxThreads = 4

   var thrs {.global.}: array[MaxThreads, Thread[World]]
   var running: array[MaxThreads, set[HasComponent]]

   let processors = countProcessors()
   let currentThreads = min(processors, MaxThreads)

   let systems = [
      (sysHandleInput, {}, {HasInputState}),
      (sysControlBall, {HasCollide}, {HasTransform2d, HasMove, HasControlBall, HasShake}),
      (sysControlBrick, {HasCollide}, {HasFade}),
      (sysControlPaddle, {HasInputState}, {HasMove}),
      (sysShake, {}, {HasTransform2d, HasShake, HasClearColor}),
      (sysFade, {HasFade}, {HasTransform2d, HasDraw2d}),
      (sysMove, {HasMove}, {HasTransform2d}),
      (sysTransform2d, {HasHierarchy}, {HasTransform2d, HasPrevious}),
      (sysCollide, {HasTransform2d}, {HasCollide})]

   var i = 0
   for (sys, reads, writes) in items(systems):
      if i >= currentThreads:
         joinThreads(thrs[0..<i])
         i = 0
      for j in 0 ..< i:
         if running[j] * (reads + writes) != {}:
            joinThreads(thrs[0..<i])
            i = 0
            break
      createThread(thrs[i], sys, self.world)
      running[i] = writes
      i.inc

   joinThreads(thrs[0..<i])

type
   ThrPool[N: static[int]; TArg] = object
      head, tail: int
      thr: array[N, Thread[TArg]
      writes: array[N, set[HasComponent]]

proc len[N, TArg](b: var ThrPool[N, TArg]): int {.inline.} =
   result = b.tail - b.head

proc spawn[N, TArg](b: var ThrPool[N, TArg];
      tp: proc (arg: TArg) {.thread, nimcall.}; param: TArg, writes: set[HasComponent]) =
   createThread(b.thr[b.tail and (N - 1)], tp, param)
   b.writes[b.tail and (N - 1)] = writes
   inc(b.tail)

proc await[N, TArg](b: var ThrPool[N, TArg], i: Natural) =
   joinThread(b.thr[(b.head + i) and (N - 1)])

proc awaitFirst[N, TArg](b: var ThrPool[N, TArg]) =
   joinThread(b.thr[b.head and (N - 1)])
   inc(b.head)

proc sync[N, TArg](b: var ThrPool[N, TArg]) =
   var i = b.head and (N - 1)
   let len = len(b)
   for c in 0 ..< len:
      joinThread(b.thr[i])
      i = (i + 1) and (N - 1)
      assert len(b) == len, "thread pool modified while iterating over it"

proc writes[N, TArg](b: var ThrPool[N, TArg], i: Natural): set[HasComponent] =
   result = b.writes[(b.head + i) and (N - 1)]

proc update(self: var Game) =
   const MaxThreads = 4

   var thrs {.global.}: ThrPool[MaxThreads, World]

   let processors = countProcessors()
   let currentThreads = min(processors, MaxThreads)

   let systems = [
      (sysHandleInput, {}, {HasInputState}),
      (sysControlBall, {HasCollide}, {HasTransform2d, HasMove, HasControlBall, HasShake}),
      (sysControlBrick, {HasCollide}, {HasFade}),
      (sysControlPaddle, {HasInputState}, {HasMove}),
      (sysShake, {}, {HasTransform2d, HasShake, HasClearColor}),
      (sysFade, {HasFade}, {HasTransform2d, HasDraw2d}),
      (sysMove, {HasMove}, {HasTransform2d}),
      (sysTransform2d, {HasHierarchy}, {HasTransform2d, HasPrevious}),
      (sysCollide, {HasTransform2d}, {HasCollide})]

   var i = 0
   for (sys, reads, writes) in items(systems):
      if i >= currentThreads:
         awaitFirst(thrs)
      for j in 0 ..< i:
         if thrs.writes(j) * (reads + writes) != {}:
            await(thrs, j)
      spawn(thrs, sys, self, writes)
      inc(i)
   sync(thrs)

proc update(self: var Game) =
   const MaxThreads = 4
   var thrs {.global.}: array[MaxThreads, Thread[World]]
   let processors = countProcessors()
   let currentThreads = min(processors, MaxThreads)

   var i = 0
   for sys in items([sysHandleInput, sysControlBall, sysControlBrick]):
      if i >= currentThreads:
         joinThread(thrs[i - 1])
         i = i - 1
      createThread(thrs[i], sys, self)
      i.inc

   joinThread(thrs[0])
   i = 0
   joinThread(thrs[1])
   i = 1
   createThread(thrs[i], sysControlPaddle, self)
   i.inc
   createThread(thrs[i], sysShake, self)
   i.inc
   joinThread(thrs[3])
   i = 3
   joinThread(thrs[1])
   i = 1
   createThread(thrs[i], sysFade, self)
   i.inc
   joinThread(thrs[0])
   i = 0
   joinThread(thrs[1])
   i = 1
   sysMove(self)
   sysTransform2d(self)
   sysCollide(self)

proc update(self: var Game) =
   # The Game engine that consist of these systems
   var thr: Thread[void]
   thr.runInBackground(Weave)
   # sysHandleInput, sysControlBall, sysControlBrick can run in parallel
   let handleInput = submit sysHandleInput(self)
   let controlBall = submit sysControlBall(self)
   let controlBrick = submit sysControlBrick(self)
   # controlPaddle depends on sysHandleInput, sysControlBall
   waitFor(handleInput)
   waitFor(controlBall)
   submitOnEvents(HasTransform2d, HasMove, HasControlBall, HasShake, sysControlPaddle(myParam))
   let controlPaddle = submit sysControlPaddle(self)
   # sysShake depends on sysControlBall
   let shake = submit sysShake(self)
   # sysFade depends on sysControlBrick, sysShake
   waitFor(controlBrick)
   waitFor(shake)
   let fade = submit sysFade(self)
   # sysMove depends on sysControlPaddle, sysFade
   waitFor(controlPaddle)
   waitFor(fade)
   let move = submit sysMove(self)
   waitFor(move)
   let transform2d = submit sysTransform2d(self)
   waitFor(transform2d)
   let collide = submit sysCollide(self)
   waitFor(collide)

proc sysHandleInput(self: var Game) =
   evHandleInput.trigger()
proc sysControlBall(self: var Game) =
   evControlBall.trigger()
proc sysControlBrick(self: var Game) =
   evControlBrick.trigger()
proc sysControlPaddle(self: var Game) =
   evControlPaddle.trigger()
proc sysShake(self: var Game) =
   evShake.trigger()
proc sysFade(self: var Game) =
   evFade.trigger()
proc sysMove(self: var Game) =
   evMove.trigger()
proc sysTransform2d(self: var Game) =
   evTransform2d.trigger()
proc sysCollide(self: var Game) =
   evCollide.trigger()

proc update(self: var Game) =
   # The Game engine that consist of these systems
   setupSubmitterThread(Weave)
   waitUntilReady(Weave)

   let
      evHandleInput = newFlowEvent()
      evControlBall = newFlowEvent()
      evControlBrick = newFlowEvent()
      evControlPaddle = newFlowEvent()
      evShake = newFlowEvent()
      evFade = newFlowEvent()
      evMove = newFlowEvent()
      evTransform2d = newFlowEvent()
      evCollide = newFlowEvent()

   # sysHandleInput, sysControlBall, sysControlBrick can run in parallel
   submit sysHandleInput(self)
   submit sysControlBall(self)
   submit sysControlBrick(self)
   # controlPaddle depends on sysHandleInput, sysControlBall
   submitOnEvents(evHandleInput, evControlBall, sysControlPaddle(myParam))
   # sysShake depends on sysControlBall
   submitOnEvent(evControlBall, sysShake(self))
   # sysFade depends on sysControlBrick, sysShake
   submitOnEvents(evControlBrick, evShake, sysFade(self))
   # sysMove depends on sysControlPaddle, sysFade
   submitOnEvents(evControlPaddle, evFade, sysMove(self))
   submitOnEvent(evMove, sysTransform2d(self))
   let collide = submitOnEvent(evTransform2d, sysCollide(self))
   waitFor(collide)

var thr: Thread[void]
thr.runInBackground(Weave)
game.update()
