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

type
   Mat2d* = object
      m00*, m10*: float32
      m01*, m11*: float32
      m02*, m12*: float32

func mat2d*(): Mat2d =
   result = Mat2d(
      m00: 1.0,
      m10: 0.0,
      m01: 0.0,
      m11: 1.0,
      m02: 0.0,
      m12: 0.0)

func fromTranslation*(v: Vec2): Mat2d =
   result = Mat2d(
      m00: 1.0,
      m10: 0.0,
      m01: 0.0,
      m11: 1.0,
      m02: v.x,
      m12: v.y)

func getTranslation*(a: Mat2d): Vec2 =
   result = Vec2(x: a.m02, y: a.m12)

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

func compose*(position, scale: Vec2, rad: float32): Mat2d =
   let s = rad.sin()
   let c = rad.cos()

   result = Mat2d(
      m00: c * scale.x,
      m10: s * scale.x,
      m01: -s * scale.y,
      m11: c * scale.y,
      m02: position.x,
      m12: position.y)

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
