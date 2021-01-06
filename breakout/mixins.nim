import gametypes, heaparrays, vmath, utils, slottables, fusion/smartptrs

template mixBody(has) =
  world.signature[entity].incl has

proc mixCollide*(world: var World, entity: Entity, size = vec2(0, 0)) =
  mixBody HasCollide
  world.collide[entity.idx] = Collide(size: size,
        collision: Collision(other: invalidId))

proc mixControlBall*(world: var World, entity: Entity) =
  mixBody HasControlBall

proc mixControlBrick*(world: var World, entity: Entity) =
  mixBody HasControlBrick

proc mixControlPaddle*(world: var World, entity: Entity) =
  mixBody HasControlPaddle

proc mixDirty*(world: var World, entity: Entity) =
  mixBody HasDirty

proc mixDraw2d*(world: var World, entity: Entity, width, height = 100'i32,
      color = [255'u8, 0, 255, 255]) =
  mixBody HasDraw2d
  world.draw2d[entity.idx] = Draw2d(width: width, height: height, color: color)

proc mixFade*(world: var World, entity: Entity, step = 0'f32) =
  mixBody HasFade
  world.fade[entity.idx] = Fade(step: step)

proc mixFresh*(world: var World, entity: Entity) =
  mixBody HasFresh

proc mixHierarchy*(world: var World, entity: Entity, parent = invalidId) =
  mixBody HasHierarchy
  world.hierarchy[entity.idx] = Hierarchy(head: invalidId, prev: invalidId,
        next: invalidId, parent: parent)
  if parent != invalidId: prepend(world, parent, entity)

proc mixMove*(world: var World, entity: Entity, direction = vec2(0, 0), speed = 10'f32) =
  mixBody HasMove
  world.move[entity.idx] = Move(direction: direction, speed: speed)

proc mixPrevious*(world: var World, entity: Entity, position = point2(0, 0),
      rotation = 0.Rad, scale = vec2(1, 1)) =
  mixBody HasPrevious
  world.previous[entity.idx] = Previous(position: position,
        rotation: rotation, scale: scale)

proc mixShake*(world: var World, entity: Entity, duration = 1'f32, strength = 0'f32) =
  mixBody HasShake
  world.shake = newUniquePtr(Shake(duration: duration, strength: strength))

proc mixTransform2d*(world: var World, entity: Entity, trworld = mat2d(), translation = vec2(0, 0),
      rotation = 0.Rad, scale = vec2(1, 1), parent = invalidId) =
  mixBody HasTransform2d
  world.transform[entity.idx] = Transform2D(world: trworld, translation: translation,
        rotation: rotation, scale: scale)
  mixHierarchy(world, entity, parent)
  mixDirty(world, entity)
  mixFresh(world, entity)
