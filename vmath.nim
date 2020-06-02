import math

func lerp*(a, b, t: float32): float32 =
   result = a * (1.0 - t) + b * t

type
   Vec2* = object
      x*, y*: float32

   UnitVec2* {.borrow:`.`.} = distinct Vec2
   Point2* {.borrow: `.`.} = distinct Vec2

func vec2*(x, y: float32): Vec2 =
   result = Vec2(x: x, y: y)

func `+`*(a, b: Vec2): Vec2 =
   result = Vec2(x: a.x + b.x, y: a.y + b.y)

func `-`*(a, b: Vec2): Vec2 =
   result = Vec2(x: a.x - b.x, y: a.y - b.y)

func `*`*(v: Vec2, scalar: float32): Vec2 =
   result = Vec2(x: v.x * scalar, y: v.y * scalar)

proc `-`*(a: Vec2): Vec2 =
   result = Vec2(x: -a.x, y: -a.y)

func `/`*(v: Vec2, scalar: float32): Vec2 =
   result = Vec2(x: v.x / scalar, y: v.y / scalar)

func lengthSq*(a: Vec2): float32 =
   result = a.x * a.x + a.y * a.y

func length*(a: Vec2): float32 =
   result = sqrt(a.lengthSq)

func normalize*(a: Vec2): UnitVec2 =
   result = UnitVec2(a / a.length)

func dot*(a, b: Vec2): float32 =
   result = a.x * b.x + a.y * b.y

func dir*(a, b: Vec2): UnitVec2 =
   result = normalize(a - b)

func dir*(rad: float32): UnitVec2 =
   result = UnitVec2(vec2(cos(rad), sin(rad)))

func lerp*(a, b: Vec2, t: float32): Vec2 =
   result = a * (1.0 - t) + b * t

func point2*(x, y: float32): Point2 =
   result = Point2(vec2(x, y))

func `*`*(p: Point2, scalar: float32): Point2 =
   result = Point2(Vec2(p) * scalar)

func `-`*(a, b: Point2): Vec2 =
   result = Vec2(a) - Vec2(b)

func `+`*(p: Point2, v: Vec2): Point2 =
   result = Point2(Vec2(p) + v)

func `-`*(p: Point2, v: Vec2): Point2 =
   result = Point2(Vec2(p) - v)

func dist*(at, to: Point2): float32 =
   result = length(at - to)

func distSq*(at, to: Point2): float32 =
   result = lengthSq(at - to)

func lerp*(a, b: Point2, t: float32): Point2 =
   result = Point2(lerp(Vec2(a), Vec2(b), t)

type
   Mat2d* = object
      m00*, m01*, m02*: float32
      m10*, m11*, m12*: float32

func identity*(): Mat2d =
   result = Mat2d(
      m00: 1.0,
      m10: 0.0,
      m01: 0.0,
      m11: 1.0,
      m02: 0.0,
      m12: 0.0)

func translate*(a: Mat2d, v: Vec2): Mat2d =
   result = Mat2d(
      m00: a.m00,
      m10: a.m10,
      m01: a.m01,
      m11: a.m11,
      m02: a.m02 + v.x,
      m12: a.m12 + v.y)

func rotate*(a: Mat2d, rad: float32): Mat2d =
   let s = rad.sin()
   let c = rad.cos()

   result = Mat2d(
      m00: a.m00 * c + a.m01 * s,
      m10: a.m10 * c + a.m11 * s,
      m01: a.m01 * -s + a.m01 * c,
      m11: a.m11 * -s + a.m11 * c,
      m02: a.m02,
      m12: a.m12)

func scale*(a: Mat2d, v: Vec2): Mat2d =
   result = Mat2d(
      m00: a.m00 * v.x,
      m10: a.m10 * v.x,
      m01: a.m01 * v.y,
      m11: a.m11 * v.y,
      m02: a.m02,
      m12: a.m12)

func compose*(translation, scale: Vec2, rad: float32): Mat2d =
   let s = rad.sin()
   let c = rad.cos()

   result = Mat2d(
      m00: c * scale.x,
      m10: s * scale.x,
      m01: -s * scale.y,
      m11: c * scale.y,
      m02: translation.x,
      m12: translation.y)

func origin*(a: Mat2d): Point2 =
   result = point2(a.m02, a.m12)

proc scale*(a: Mat2d): Vec2 =
   result = vec2(vec2(a.m00, a.m01).length, vec2(a.m01, a.m11).length)

proc rotation*(a: Mat2d): float32 =
   result = arctan2(a.m01, a.m00)

proc lerp*(a, b: Mat2d, t: float32): Mat2d =
   # extract parameters
   let p1 = a.origin
   let r1 = a.rotation
   let s1 = a.scale

   let p2 = b.origin
   let r2 = b.rotation
   let s2 = b.scale

   # slerp rotation
   let v1 = dir(r1).Vec2
   let v2 = dir(r2).Vec2

   var dot = dot(v1, v2)
   dot = clamp(dot, -1.0, 1.0)

   var v: Vec2
   if dot > 0.9995:
      v = normalize(lerp(v1, v2, t)).Vec2 # linearly interpolate to avoid numerical precision issues
   else:
      let angle = t * arccos(dot)
      let v3 = normalize(v2 - v1 * dot).Vec2
      v = v1 * cos(angle) + v3 * sin(angle)

   # construct matrix
   result = compose(lerp(p1, p2, t), lerp(s1, s2, t), arctan2(v.y, v.x))

func invert*(a: Mat2d): Mat2d =
   let aa = a.m00
   let ab = a.m10
   let ac = a.m01
   let ad = a.m11
   let atx = a.m02
   let aty = a.m12

   var det = aa * ad - ab * ac

   if det == 0.0:
      raise newException(DivByZeroDefect, "Mat2d determinant cannot be 0")

   det = 1.0 / det

   result = Mat2d(
      m00: ad * det,
      m10: -ab * det,
      m01: -ac * det,
      m11: aa * det,
      m02: (ac * aty - ad * atx) * det,
      m12: (ab * atx - aa * aty) * det)

func `*`*(a, b: Mat2d): Mat2d =
   let a0 = a.m00
   let a1 = a.m10
   let a2 = a.m01
   let a3 = a.m11
   let a4 = a.m02
   let a5 = a.m12
   let b0 = b.m00
   let b1 = b.m10
   let b2 = b.m01
   let b3 = b.m11
   let b4 = b.m02
   let b5 = b.m12

   result = Mat2d(
      m00: a0 * b0 + a2 * b1,
      m10: a1 * b0 + a3 * b1,
      m01: a0 * b2 + a2 * b3,
      m11: a1 * b2 + a3 * b3,
      m02: a0 * b4 + a2 * b5 + a4,
      m12: a1 * b4 + a3 * b5 + a5)

proc transform*(a: Mat2d, v: Vec2): Vec2 =
   result = vec2(a.m00 * v.x + a.m01 * v.y,
         a.m10 * v.x + a.m11 * v.y)

proc transform*(a: Mat2d, p: Point2): Point2 =
   result = point2(a.m00 * p.x + a.m01 * p.y + a.m02,
         a.m10 * p.x + a.m11 * p.y + a.m12)
