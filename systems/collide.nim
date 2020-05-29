import ".." / [game_types, vmath, sparse_set], math

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
      result = vec2(penetrationX * sgn(distanceX).float32, 0)
   else:
      result = vec2(0, penetrationY * sgn(distanceY).float32)

proc sysCollide*(game: var Game) =
   var allColliders: seq[Collide]
   for i in 0 ..< MaxEntities:
      if game.world[i] * Query == Query:
         template transform: untyped = game.transform[Entity(i)]
         template collider: untyped = game.collide[Entity(i)]

         collider.collision.entity = invalidId
         computeAabb(transform, collider)
         allColliders.add(collider)

   for i in 0 ..< allColliders.len:
      template collider: untyped = allColliders[i]
      for j in i + 1 ..< allColliders.len:
         template other: untyped = allColliders[j]

         if collider.entity != other.entity and intersectAabb(collider, other):
            collider.collision = Collision(
               entity: other.entity,
               hit: calculatePenetration(collider, other))
            game.collide[collider.entity] = collider

            other.collision = Collision(
               entity: collider.entity,
               hit: calculatePenetration(other, collider))
            game.collide[other.entity] = other
