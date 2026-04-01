import std/math
import vmath

type
  BenchScale* = object
    columns*: int
    rows*: int

const
  DefaultBenchScale* = BenchScale(columns: 10, rows: 10)

proc mixBits(value: uint32): uint32 =
  result = value
  result = result xor (result shr 16)
  result *= 0x7feb352d'u32
  result = result xor (result shr 15)
  result *= 0x846ca68b'u32
  result = result xor (result shr 16)

proc quantize(value: float32): uint32 =
  result = cast[uint32](value * 1000)

proc eventSeed*(stream: uint32; tickId: int; x, y: float32): uint32 =
  result = mixBits(stream xor uint32(tickId))
  result = mixBits(result xor quantize(x))
  result = mixBits(result xor quantize(y))

proc chanceFromSeed*(seed: uint32): float32 =
  let bits = mixBits(seed) and 0x00ff_ffff'u32
  result = bits.float32 / 0x0100_0000'u32.float32

proc angleFromSeed*(seed: uint32): Rad =
  result = (PI.float32 + chanceFromSeed(seed) * PI.float32).Rad

proc shakeOffsetFromTick*(tickId, axis: int; strength: float32): float32 =
  let seed = eventSeed(17'u32 + axis.uint32, tickId, strength, axis.float32)
  result = (chanceFromSeed(seed) * 2 - 1) * strength

proc shakeColorFromTick*(tickId, channel: int): uint8 =
  let seed = eventSeed(29'u32 + channel.uint32, tickId, channel.float32, 0)
  result = uint8(mixBits(seed) and 0xff'u32)
