const rt = @import("rtweekend.zig");

const Self = @This();
pub const Ray = Self;

origin: rt.Point3,
direction: rt.Vec3,

pub fn at(self: Self, t: f64) rt.Point3 {
    return self.origin.add(self.direction.multiply(t));
}

