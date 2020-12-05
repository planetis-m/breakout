import game_types, vmath, utils, registry, storage, fusion/smartptrs

template mixBody(has) =
   game.world[entity].incl has

proc mixCollide*(game: var Game, entity: Entity, size = vec2(0, 0)) =
   mixBody HasCollide
   game.collide[entity.index] = Collide(size: size,
         collision: Collision(other: invalidId))

proc mixControlBall*(game: var Game, entity: Entity) =
   mixBody HasControlBall

proc mixControlBrick*(game: var Game, entity: Entity) =
   mixBody HasControlBrick

proc mixControlPaddle*(game: var Game, entity: Entity) =
   mixBody HasControlPaddle

proc mixDirty*(game: var Game, entity: Entity) =
   mixBody HasDirty

proc mixDraw2d*(game: var Game, entity: Entity, width, height = 100'i32,
      color = [255'u8, 0, 255, 255]) =
   mixBody HasDraw2d
   game.draw2d[entity.index] = Draw2d(width: width, height: height, color: color)

proc mixFade*(game: var Game, entity: Entity, step = 0.0) =
   mixBody HasFade
   game.fade[entity.index] = Fade(step: step)

proc mixFresh*(game: var Game, entity: Entity) =
   mixBody HasFresh

proc mixHierarchy*(game: var Game, entity: Entity, parent = invalidId) =
   mixBody HasHierarchy
   game.hierarchy[entity.index] = Hierarchy(head: invalidId, prev: invalidId,
         next: invalidId, parent: parent)
   if parent != invalidId: prepend(game, parent, entity)

proc mixMove*(game: var Game, entity: Entity, direction = vec2(0, 0), speed = 10.0) =
   mixBody HasMove
   game.move[entity.index] = Move(direction: direction, speed: speed)

proc mixPrevious*(game: var Game, entity: Entity, position = point2(0, 0),
      rotation = 0.Rad, scale = vec2(1, 1)) =
   mixBody HasPrevious
   game.previous[entity.index] = Previous(position: position,
         rotation: rotation, scale: scale)

proc mixShake*(game: var Game, entity: Entity, duration = 1.0, strength = 0.0) =
   mixBody HasShake
   game.shake = newUniquePtr(Shake(duration: duration, strength: strength))

proc mixTransform2d*(game: var Game, entity: Entity, world = mat2d(), translation = vec2(0, 0),
      rotation = 0.Rad, scale = vec2(1, 1)) =
   mixBody HasTransform2d
   game.transform[entity.index] = Transform2D(world: world, translation: translation,
         rotation: rotation, scale: scale)
