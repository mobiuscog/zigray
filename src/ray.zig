const rt = @import("rtweekend.zig");

pub const Ray = struct {
    origin: rt.Point3,
    direction: rt.Vec3,

    pub fn at(self: Ray, t: f64) rt.Point3 {
        return self.origin.add(self.direction.multiply(t));
    }

    pub fn colour(self: Ray, world: rt.Hittable) rt.Colour {
        var rec: rt.Hittable.HitRecord = .{.p = .{ .x = 0, .y = 0, .z = 0}, .is_front = false, .normal = .{ .x = 0, .y = 0, .z = 0}, .t = 0, };
        if (world.hit(self, 0, rt.INFINITY, &rec)) {
            const tmp = rec.normal.add(.{ .x = 1.0, .y = 1.0, .z = 1.0,}).multiply(0.5);
            return rt.Colour {.r = tmp.x, .g = tmp.y, .b = tmp.z};
        }

        const unit_direction = self.direction.unit_vector();
        const a = 0.5 * (unit_direction.y + 1.0);
        return rt.Colour.Colours.WHITE.multiply(1.0 - a).add(rt.Colour.Colours.SKY.multiply(a));
    }
};