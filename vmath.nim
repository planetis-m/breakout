import math

func lerp*(a, b, v: float32): float32 =
   result = a * (1.0 - v) + b * v

type
   Vec2* = object
      x*: float32
      y*: float32

func vec2*(x, y: float32): Vec2 =
   result = Vec2(x: x, y: y)

proc `-`*(a: Vec2): Vec2 =
   result = Vec2(x: -a.x, y: -a.y)

# m00: 1.0 m10: 1.0
# m01: 0.0 m11: v.x
# m02: 0.0 m12: v.y
#
# m00: 1.0 m02: 0.0
# m01: 0.0 m10: 1.0
# m11: v.x m12: v.y
#
# m00: 1.0 m10: 0.0
# m01: 0.0 m11: 1.0
# m02: v.x m12: v.y

type
   Mat2d* = object
      m00*: float32
      m01*: float32
      m02*: float32
      m10*: float32
      m11*: float32
      m12*: float32

func mat2d*(): Mat2d =
   result = Mat2d(
      m00: 1.0,
      m01: 0.0,
      m02: 0.0,
      m10: 1.0,
      m11: 0.0,
      m12: 0.0)

func fromTranslation*(v: Vec2): Mat2d =
   result = Mat2d(
      m00: 1.0,
      m01: 0.0,
      m02: 0.0,
      m10: 1.0,
      m11: v.x,
      m12: v.y)

func getTranslation*(a: Mat2d): Vec2 =
   result = Vec2(x: a.m11, y: a.m12)

func rotate*(a: Mat2d, rad: float32): Mat2d =
   let s = rad.sin()
   let c = rad.cos()

   result = Mat2d(
      m00: a.m00 * c + a.m02 * s,
      m01: a.m01 * c + a.m10 * s,
      m02: a.m02 * -s + a.m02 * c,
      m10: a.m10 * -s + a.m10 * c,
      m11: a.m11,
      m12: a.m12)

func scale*(a: Mat2d, v: Vec2): Mat2d =
   result = Mat2d(
      m00: a.m00 * v.x,
      m01: a.m01 * v.x,
      m02: a.m02 * v.y,
      m10: a.m10 * v.y,
      m11: a.m11,
      m12: a.m12)

func invert*(a: Mat2d): Mat2d =
   let aa = a.m00
   let ab = a.m01
   let ac = a.m02
   let ad = a.m10
   let atx = a.m11
   let aty = a.m12

   var det = aa * ad - ab * ac

   if det == 0.0:
      raise newException(DivByZeroDefect, "Mat2d determinant cannot be 0")

   det = 1.0 / det

   result = Mat2d(
      m00: ad * det,
      m01: -ab * det,
      m02: -ac * det,
      m10: aa * det,
      m11: (ac * aty - ad * atx) * det,
      m12: (ab * atx - aa * aty) * det)

func `*`*(a, b: Mat2d): Mat2d =
   let a0 = a.m00
   let a1 = a.m01
   let a2 = a.m02
   let a3 = a.m10
   let a4 = a.m11
   let a5 = a.m12
   let b0 = b.m00
   let b1 = b.m01
   let b2 = b.m02
   let b3 = b.m10
   let b4 = b.m11
   let b5 = b.m12

   result = Mat2d(
      m00: a0 * b0 + a2 * b1,
      m01: a1 * b0 + a3 * b1,
      m02: a0 * b2 + a2 * b3,
      m10: a1 * b2 + a3 * b3,
      m11: a0 * b4 + a2 * b5 + a4,
      m12: a1 * b4 + a3 * b5 + a5)
