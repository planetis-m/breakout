import ../vmath, ../dsl, ../game_types, ../sparse_set, ../systems / [transform2d, collide]

proc update(game: var Game, isFirst: bool) =
   # The Game engine that consist of these systems
   sysCollide(game)
   sysTransform2d(game, isFirst)

proc getBrick(game: var Game, parent = game.camera, x, y: float32, width, height: int32): Entity =
   result = game.addBlueprint:
      translation = Vec2(x: x, y: y)
      parent = parent
      with Collide(size: Vec2(x: width.float32, y: height.float32))

proc sceneMain(game: var Game) =
   let columnCount = 100
   let rowCount = 50
   let brickWidth = 50
   let brickHeight = 15
   let margin = 5

   let gridWidth = brickWidth * columnCount + margin * (columnCount - 1)
   let startingX = (game.windowWidth - gridWidth) div 2
   let startingY = 50

   game.camera = game.addBlueprint:
      children:
         for row in 0 ..< rowCount:
            let y = startingY + row * (brickHeight + margin) + brickHeight div 2
            for col in 0 ..< columnCount:
               let x = startingX + col * (brickWidth + margin) + brickWidth div 2
               entity getBrick(x.float32, y.float32, brickWidth.int32, brickHeight.int32)

import times, stats, strformat

proc printStats(name: string, stats: RunningStat, dur: float) =
   echo &"""{name}:
   Collected {stats.n} samples in {dur:.4} seconds
   Average time: {stats.mean * 1000:.4} ms
   Stddev  time: {stats.standardDeviationS * 1000:.4} ms
   Min     time: {stats.min * 1000:.4} ms
   Max     time: {stats.max * 1000:.4} ms"""

proc run =
   var game = Game(
      world: newSeq[set[HasComponent]](MaxEntities),

      collide: initSparseSet[Collide](MaxEntities),
      hierarchy: initSparseSet[Hierarchy](MaxEntities),
      previous: initSparseSet[Previous](MaxEntities),
      transform: initSparseSet[Transform2d](MaxEntities))

   sceneMain(game)

   var stats: RunningStat
   let globalStart = cpuTime()
   for i in 1..100:
      let start = cpuTime()
      game.update(i mod 10 == 0)
      let duration = cpuTime() - start
      stats.push duration
   let globalDuration = cpuTime() - globalStart
   printStats("Run update", stats, globalDuration)

run()
