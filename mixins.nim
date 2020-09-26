import game_types, vmath, utils, registry, storage

proc mixCollide*(game: var Game, entity: Entity, size = vec2(0, 0)) =
   game.world[entity].incl HasCollide
   game.collide[entity.index] = Collide(size: size,
         collision: Collision(other: invalidId))

proc mixControlBall*(game: var Game, entity: Entity) =
   game.world[entity].incl HasControlBall

proc mixControlBrick*(game: var Game, entity: Entity) =
   game.world[entity].incl HasControlBrick

proc mixControlPaddle*(game: var Game, entity: Entity) =
   game.world[entity].incl HasControlPaddle

proc mixDirty*(game: var Game, entity: Entity) =
   game.world[entity].incl HasDirty

proc mixDraw2d*(game: var Game, entity: Entity, width, height = 100'i32,
      color = [255'u8, 0, 255, 255]) =
   game.world[entity].incl HasDraw2d
   game.draw2d[entity.index] = Draw2d(width: width, height: height, color: color)

proc mixFade*(game: var Game, entity: Entity, step = 0.0) =
   game.world[entity].incl HasFade
   game.fade[entity.index] = Fade(step: step)

proc mixFresh*(game: var Game, entity: Entity) =
   game.world[entity].incl HasFresh

proc mixHierarchy*(game: var Game, entity: Entity, parent = invalidId) =
   game.world[entity].incl HasHierarchy
   game.hierarchy[entity.index] = Hierarchy(head: invalidId, prev: invalidId,
         next: invalidId, parent: parent)
   if parent != invalidId: prepend(game, parent, entity)

proc mixMove*(game: var Game, entity: Entity, direction = vec2(0, 0), speed = 10.0) =
   game.world[entity].incl HasMove
   game.move[entity.index] = Move(direction: direction, speed: speed)

proc mixPrevious*(game: var Game, entity: Entity, position = point2(0, 0),
      rotation = 0.Rad, scale = vec2(1, 1)) =
   game.world[entity].incl HasPrevious
   game.previous[entity.index] = Previous(position: position,
         rotation: rotation, scale: scale)

proc mixShake*(game: var Game, entity: Entity, duration = 1.0, strength = 0.0) =
   game.world[entity].incl HasShake
   game.shake = Shake(duration: duration, strength: strength)

proc mixTransform2d*(game: var Game, entity: Entity, world = identity(), translation = vec2(0, 0),
      rotation = 0.Rad, scale = vec2(1, 1)) =
   game.world[entity].incl HasTransform2d
   game.transform[entity.index] = Transform2D(world: world, translation: translation,
         rotation: rotation, scale: scale)
