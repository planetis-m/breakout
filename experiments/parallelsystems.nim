type
   RunningSystem = object
      readMask, writeMask: ComponentMask
      thread: Thread[World]
      threadJoined: bool

   World = object
      componentMasks: seq[ComponentMask]
      entityValid: seq[bool]
      # the free list is a min heap, so that we try to fill lower indices first
      entityIdFreeList: HeapQueue[EntityHandle]
      runningSystems: seq[RunningSystem]
      pools: array[MaxComponents, ComponentPoolBase]
      lock: Lock

proc waitForSystems(self: var World, readMask, writeMask: ComponentMask) =
   for system in self.runningSystems:
      # if a running system writes to a component we want to read from or write to, wait until it is finished
      if system.writeMask * (readMask + writeMask) != {}:
         system.thread.joinThread()
         system.threadJoined = true
   var i = self.runningSystems.high
   while i >= 0:
      if self.runningSystems[i].threadJoined:
         self.runningSystems.delete(i)
      dec(i)

proc joinSystemThreads(self: var World) =
    for system in self.runningSystems: system.thread.join()
    self.runningSystems.shrink(0)

proc createEntity(self: var World): EntityHandle =
   acquire(self.lock)
   if self.entityIdFreeList.len == 0:
      self.componentMasks.add(0)
      self.entityValid.add(false)
      assert(self.componentMasks.len == self.entityValid.len)
      result = EntityHandle(self, self.componentMasks.high)
   else:
      let entityId = self.entityIdFreeList.pop()
      assert(entityId < self.componentMasks.len and entityId < self.entityValid.len
      self.componentMasks[entityId] = 0
      self.entityValid[entityId] = false
      result = EntityHandle(self, entityId)
   release(self.lock)

proc tickSystem(self: World, async, parallelFor: bool, tickFunc: FuncType, funcArgs: varargs[FuncArgs]) =
    # Component types must not be references
    # Tick function has invalid signature

   let readMask = constFilteredComponentMask<true, Components...>()
   let writeMask = constFilteredComponentMask<false, Components...>()
   assert(readMask + writeMask == componentMask<Components...>())
   waitForSystems(readMask, writeMask)

   std::function<void(EntityHandle)> tickEntity
   if constexpr(funcValidWithEntityHandle):
      tickEntity = [tickFunc, &funcArgs...](EntityHandle e) {
         tickFunc(e, std::forward<FuncArgs>(funcArgs)..., e.get<Components>()...)
   else:
      tickEntity = [tickFunc, &funcArgs...](EntityHandle e) {
         tickFunc(std::forward<FuncArgs>(funcArgs)..., e.get<Components>()...)

   proc tickAll(this: World, parallelFor: bool, tickEntity: seq[]) {.thread.} =
      if parallelFor:
         forEachEntity<Components...>(tickEntity, std::execution::par)
      else:
         forEachEntity<Components...>(tickEntity, std::execution::seq)

   if async:
      var system = RunningSystem(readMask: readMask, writeMask: writeMask)
      createThread(system.thread, threadFunc, this, system, tickFunc, funcArgs)

      self.runningSystems.add(system)
   else:
      tickAll()
