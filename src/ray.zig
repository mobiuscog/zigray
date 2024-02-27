const std = @import("std");
const Vec3 = @import("vector.zig").Vec3;
const Point3 = Vec3;
const Colour = @import("colour.zig").Colour;
const Colours = @import("colour.zig").Colours;

pub const Ray = struct {
    origin: Point3,
    direction: Vec3,

    pub fn at(self: Ray, t: f64) Point3 {
        return self.origin.add(self.direction.multiply(t));
    }

    pub fn hit_sphere(self: Ray, center: Point3, radius: f64) bool {
        const oc = self.origin.subtract(center);
        const a = self.direction.dot(self.direction);
        const b = 2.0 * oc.dot(self.direction);
        const c = oc.dot(oc) - radius * radius;
        const discriminant = b*b - 4*a*c;
        return (discriminant >= 0);
    }

    pub fn colour(self: Ray) Colour {
        if (self.hit_sphere(Point3 {.x = 0, .y = 0, .z = -1}, 0.5)) {
            return Colours.RED;
        }

        const unit_direction = self.direction.unit_vector();
        const a = 0.5 * (unit_direction.y + 1.0);
        return Colours.WHITE.multiply(1.0 - a).add(Colours.SKY.multiply(a));
    }
};