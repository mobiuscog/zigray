const std = @import("std");
const rt = @import("rtweekend.zig");


pub const Hittable = struct {

    pub const HitRecord = struct {
        p: rt.Point3,
        normal: rt.Vec3,
        t: f64,
        is_front: bool,


        pub fn set_face_normal(self: *HitRecord, r: rt.Ray, outward_normal: rt.Vec3) void {
            // Sets the hit record normal vector.
            // NOTE: the parameter `outward_normal` is assumed to have unit length.
            self.is_front = r.direction.dot(outward_normal) < 0;
            self.normal = if (self.is_front) outward_normal else outward_normal.negate();
        }
    };

    ptr: *anyopaque,
    hitFn: *const fn (ptr: *anyopaque, ray: rt.Ray, tmin: f64, tmax: f64, record: *HitRecord) bool,

    pub fn hit(self: Hittable, ray: rt.Ray, tmin: f64, tmax: f64, record: *HitRecord) bool {
        return self.hitFn(self.ptr, ray, tmin, tmax, record);
    }
};

pub const Scene = struct {
    internal: struct {
        objects: std.ArrayList(Hittable),
        allocator: std.mem.Allocator,
    },

    has_printed: bool,

    pub fn init(allocator: std.mem.Allocator) !Scene {
        return Scene {
            .internal = .{
                .objects = std.ArrayList(Hittable).init(allocator),
                .allocator = allocator,
            },
            .has_printed = false,
        };
    }

    pub fn deinit(self: *Scene) void {
        self.internal.objects.deinit();
    }

    pub fn add(self: *Scene, object: Hittable) !void {
        try self.internal.objects.append(object);
    }

    pub fn asHittable(self: *Scene) Hittable {
        return Hittable {
        .ptr = self,
        .hitFn = hit,
        };
    }

    pub fn hit(ptr: *anyopaque, r: rt.Ray, tmin: f64, tmax: f64, rec: *Hittable.HitRecord) bool {
        const self: *Scene = @ptrCast(@alignCast(ptr));
        var temp_rec = Hittable.HitRecord {.p = .{ .x = 0, .y = 0, .z = 0}, .is_front = false, .normal = .{ .x = 0, .y = 0, .z = 0}, .t = 0, };
        var hit_anything = false;
        var closest_so_far = tmax;

        if (!self.has_printed) {
            self.has_printed = true;
            std.debug.print("item count {}", .{self.internal.objects.items.len});
        }

        for (self.internal.objects.items) |object| {
            if (object.hit(r, tmin, closest_so_far, &temp_rec)) {
                hit_anything = true;
                closest_so_far = temp_rec.t;
                rec.t = temp_rec.t;
                rec.normal = temp_rec.normal;
                rec.is_front = temp_rec.is_front;
                rec.p = temp_rec.p;
            }
        }

        return hit_anything;
    }

};

pub const Sphere = struct {
    center: rt.Point3,
    radius: f64,

    pub fn init(center: rt.Point3, radius: f64) Sphere {
        return Sphere  { .center = center, .radius = radius, };
    }

    pub fn asHittable(self: *Sphere) Hittable {
        return Hittable {
            .ptr = self,
            .hitFn = hit,
        };
    }

    pub fn hit(ptr: *anyopaque, ray: rt.Ray, tmin: f64, tmax: f64, record: *Hittable.HitRecord) bool {
        const self: *Sphere = @ptrCast(@alignCast(ptr));
        const oc = ray.origin.subtract(self.center);
        const a = ray.direction.lengthSquared();
        const half_b = oc.dot(ray.direction);
        const c = oc.lengthSquared() - self.radius * self.radius;


        const discriminant = half_b * half_b - a * c;
        if (discriminant < 0) {
            return false;
        }
        const sqrtd = std.math.sqrt(discriminant);

        // Find the nearest root that lies in the acceptable range
        var root = (-half_b - sqrtd) / a;
        if (root <= tmin or tmax <= root) {
            root = (-half_b + sqrtd) / a;
            if (root <= tmin or tmax <= root) {
                return false;
            }
        }

        record.t = root;
        record.p = ray.at(record.t);
        // record.normal = record.p.subtract(self.center).divide(self.radius);
        const outward_normal = (record.p.subtract(self.center)).divide(self.radius);
        record.set_face_normal(ray, outward_normal);

        return true;
    }
};