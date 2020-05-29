proc cmp(game: var Game; x, y: Entity): bool =
   template hierX: untyped = game.hierarchy[x]
   template hierY: untyped = game.hierarchy[y]

   hierY.parent == x or hierX.next == y or
      (hierX.parent != y and hierX.next != y) and
      (hierY.parent < hierY.parent or (hierX.parent == hierX.parent and hierX < hierY)))

proc sort*(game: var Game) =
   template transX: untyped = game.transform[i]
   template transY: untyped = game.transform[j]
   template transYp1: untyped = game.transform[j]

   for i in 1 ..< MaxEntities:
      if transX.dirty:
         var j = i - 1
         while j >= 0 and transY.dirty and cmp(game, i, j):
            transYp1 = transY
            dec(j)
         transYp1 = transX
