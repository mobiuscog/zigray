const std = @import("std");
const Vec3 = @import("vector.zig").Vec3;
const Point3 = Vec3;
const Colour = @import("colour.zig").Colour;

pub const Ray = struct {
    origin: Point3,
    direction: Vec3,

    pub fn at(self: Ray, t: f64) Point3 {
        return self.origin.add(self.direction.multiply(t));
    }
};