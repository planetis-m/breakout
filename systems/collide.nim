import ".." / [game_types, vmath, registry, storage], math

const Query = {HasTransform2d, HasCollide}

proc computeAabb(transform: Transform2d, collide: var Collide) =
   collide.center = origin(transform.world)
   collide.min = collide.center - collide.size / 2.0
   collide.max = collide.center + collide.size / 2.0

proc intersectAabb(a, b: Collide): bool =
   a.min.x < b.max.x and
      a.max.x > b.min.x and
      a.min.y < b.max.y and
      a.max.y > b.min.y

proc calculatePenetration(a, b: Collide): Vec2 =
   let distanceX = a.center.x - b.center.x
   let penetrationX = a.size.x / 2.0 + b.size.x / 2.0 - abs(distanceX)

   let distanceY = a.center.y - b.center.y
   let penetrationY = a.size.y / 2.0 + b.size.y / 2.0 - abs(distanceY)

   if penetrationX < penetrationY:
      result = vec2(penetrationX * sgn(distanceX).float32, 0)
   else:
      result = vec2(0, penetrationY * sgn(distanceY).float32)

proc sysCollide*(game: var Game) =
   var allColliders: seq[Entity]
   for (colliderId, has) in game.world.pairs:
      if has * Query == Query:
         template transform: untyped = game.transform[colliderId.index]
         template collider: untyped = game.collide[colliderId.index]

         collider.collision.entity = invalidId
         computeAabb(transform, collider)
         allColliders.add(colliderId)

   for i in 0 ..< allColliders.len:
      let colliderId = allColliders[i]
      template collider: untyped = game.collide[colliderId.index]

      for j in i + 1 ..< allColliders.len:
         let otherId = allColliders[j]
         template other: untyped = game.collide[otherId.index]

         if intersectAabb(collider, other):
            let penetration = calculatePenetration(collider, other)
            collider.collision = Collision(
               other: otherId, hit: penetration)

            other.collision = Collision(
               other: colliderId, hit: -penetration)
