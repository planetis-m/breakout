include storage, math

let ent = Entity(5)
var a = initStorage[float32](10)
a[ent] = 3'f32
assert a.len == 1
assert almostEqual(a[ent], 3'f32)
a.delete(ent)
assert a.len == 0
doAssertRaises(KeyError):
  discard a[ent]
