import math

type
   Rad* = distinct float32

proc `-`*(rad: Rad): Rad {.borrow.}
func `+`*(a, b: Rad): Rad {.borrow.}
func `-`*(a, b: Rad): Rad {.borrow.}
proc `<`*(a, b: Rad): bool {.borrow.}
proc `<=`*(a, b: Rad): bool {.borrow.}
proc `+=`*(a: var Rad; b: Rad) {.borrow.}
proc `-=`*(a: var Rad; b: Rad) {.borrow.}
func sin*(rad: Rad): float32 {.borrow.}
func cos*(rad: Rad): float32 {.borrow.}

func lerp*(a, b, t: float32): float32 =
   result = a * (1.0'f32 - t) + b * t

func wrapToPi*(rad: Rad): Rad =
   result = rad
   while result > Pi.Rad: result -= Tau.Rad
   while result < -Pi.Rad: result += Tau.Rad

func lerp*(a, b: Rad, t: float32): Rad =
   result = lerp(a.float32, float32(a + wrapToPi(b - a)), t).Rad

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

func magSq*(v: Vec2): float32 =
   result = v.x * v.x + v.y * v.y

func mag*(v: Vec2): float32 =
   result = sqrt(v.magSq)

func normalize*(v: Vec2): UnitVec2 =
   result = UnitVec2(v / v.mag)

func dot*(a, b: Vec2): float32 =
   result = a.x * b.x + a.y * b.y

func dir*(a, b: Vec2): UnitVec2 =
   result = normalize(a - b)

func dir*(rad: Rad): UnitVec2 =
   result = UnitVec2(vec2(cos(rad), sin(rad)))

func lerp*(a, b: Vec2, t: float32): Vec2 =
   result = a * (1.0'f32 - t) + b * t

func heading*(v: Vec2): Rad =
   result = arctan2(v.y, v.x).Rad

func point2*(x, y: float32): Point2 =
   result = Point2(vec2(x, y))

func `*`*(p: Point2, scalar: float32): Point2 =
   result = Point2(Vec2(p) * scalar)

func `+`*(a, b: Point2): Point2 {.
      error: "Adding 2 Point2 doesn't make physical sense".}

func `-`*(a, b: Point2): Vec2 =
   result = Vec2(a) - Vec2(b)

func `+`*(p: Point2, v: Vec2): Point2 =
   result = Point2(Vec2(p) + v)

func `-`*(p: Point2, v: Vec2): Point2 =
   result = Point2(Vec2(p) - v)

func dist*(a, b: Point2): float32 =
   result = mag(a - b)

func distSq*(a, b: Point2): float32 =
   result = magSq(a - b)

func lerp*(a, b: Point2, t: float32): Point2 =
   result = Point2(lerp(Vec2(a), Vec2(b), t))

type
   Mat2d* = object
      m00*, m01*: float32
      m10*, m11*: float32
      m20*, m21*: float32

func identity*(): Mat2d =
   result = Mat2d(
      m00: 1.0,
      m01: 0.0,
      m10: 0.0,
      m11: 1.0,
      m20: 0.0,
      m21: 0.0)

func translate*(a: Mat2d, v: Vec2): Mat2d =
   result = Mat2d(
      m00: a.m00,
      m01: a.m01,
      m10: a.m10,
      m11: a.m11,
      m20: a.m20 + v.x,
      m21: a.m21 + v.y)

func rotate*(a: Mat2d, rotation: Rad): Mat2d =
   let s = rotation.sin()
   let c = rotation.cos()

   result = Mat2d(
      m00: a.m00 * c + a.m10 * s,
      m01: a.m01 * c + a.m11 * s,
      m10: a.m10 * -s + a.m10 * c,
      m11: a.m11 * -s + a.m11 * c,
      m20: a.m20,
      m21: a.m21)

func scale*(a: Mat2d, v: Vec2): Mat2d =
   result = Mat2d(
      m00: a.m00 * v.x,
      m01: a.m01 * v.x,
      m10: a.m10 * v.y,
      m11: a.m11 * v.y,
      m20: a.m20,
      m21: a.m21)

func compose*(translation: Vec2, rotation: Rad, scale: Vec2): Mat2d =
   let s = rotation.sin()
   let c = rotation.cos()

   result = Mat2d(
      m00: c * scale.x,
      m01: -s * scale.y,
      m10: s * scale.x,
      m11: c * scale.y,
      m20: translation.x,
      m21: translation.y)

func origin*(a: Mat2d): Point2 =
   result = point2(a.m20, a.m21)

proc scale*(a: Mat2d): Vec2 =
   result = vec2(vec2(a.m00, a.m10).mag, vec2(a.m10, a.m11).mag)

proc rotation*(a: Mat2d): Rad =
   result = arctan2(a.m10, a.m00).Rad

proc lerp*(a, b: Mat2d, t: float32): Mat2d =
   # extract parameters
   let p1 = a.origin
   let r1 = a.rotation
   let s1 = a.scale

   let p2 = b.origin
   let r2 = b.rotation
   let s2 = b.scale

   # construct matrix
   result = compose(lerp(p1, p2, t).Vec2, lerp(r1, r2, t), lerp(s1, s2, t)) # ffs

func invert*(a: Mat2d): Mat2d =
   var det = a.m00 * a.m11 - a.m01 * a.m10

   if det == 0.0:
      raise newException(DivByZeroDefect, "Mat2d determinant cannot be 0")

   det = 1.0'f32 / det

   result = Mat2d(
      m00: a.m11 * det,
      m01: -a.m01 * det,
      m10: -a.m10 * det,
      m11: a.m00 * det,
      m20: (a.m10 * a.m21 - a.m11 * a.m20) * det,
      m21: (a.m01 * a.m20 - a.m00 * a.m21) * det)

func `*`*(a, b: Mat2d): Mat2d =
   result = Mat2d(
      m00: a.m00 * b.m00 + a.m01 * b.m10,
      m01: a.m00 * b.m01 + a.m01 * b.m11,
      m10: a.m10 * b.m00 + a.m11 * b.m10,
      m11: a.m10 * b.m01 + a.m11 * b.m11,
      m20: a.m20 * b.m00 + a.m21 * b.m10 + b.m20,
      m21: a.m20 * b.m01 + a.m21 * b.m11 + b.m21)

proc transform*(a: Mat2d, v: Vec2): Vec2 =
   result = vec2(a.m00 * v.x + a.m10 * v.y,
         a.m01 * v.x + a.m11 * v.y)

proc transform*(a: Mat2d, p: Point2): Point2 =
   result = point2(a.m00 * p.x + a.m10 * p.y + a.m20,
         a.m01 * p.x + a.m11 * p.y + a.m21)
