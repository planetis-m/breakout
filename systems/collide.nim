import game_types, vmath

const Query = {HasTransform2d, HasCollide}

proc computeAabb(transform: Transform2d, collide: var Collide) =
   collide.center = getTranslation(transform.world)
   collide.min.x = collide.center.x - collide.size.x / 2.0
   collide.min.y = collide.center.y - collide.size.y / 2.0
   collide.max.x = collide.center.x + collide.size.x / 2.0
   collide.max.y = collide.center.y + collide.size.y / 2.0

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
      penetration.x = penetrationX * sgn(distanceX)
      penetration.y = 0.0
   else:
      penetration.x = 0.0
      penetration.y = penetrationY * sgn(distanceY)

proc sysCollide*(game: var Game) =
   var allColliders: seq[Collide]
   for i in 0 ..< MaxEntities:
      if game.world[i] * Query != {}:
         template transform: untyped = game.transform[i]
         template collider: untyped = game.collide[i]

         collider.collision.entity = -1
         computeAabb(transform, collider)
         allColliders.add(collider)

   for i in 0 ..< allColliders.len:
      template collider: untyped = allColliders[i]
      for j in 0 ..< allColliders.len:
         template other: untyped = allColliders[j]
         if collider.entity != other.entity and intersectAabb(collider, other):
            collider.collision = Collision(
               entity: other.entity,
               hit: calculatePenetration(collider, other))
            game.collide[collider.entity] = collider
