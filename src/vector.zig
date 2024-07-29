const std = @import("std");
const rt = @import("rtweekend.zig");

// There are native optimised types for this in Zig, but they are recreated here for the sake of learning
const Self = @This();
pub const Vec3 = Self;
pub const Point3 = Self;

x: f64,
y: f64,
z: f64,

pub const ORIGIN = init(0, 0, 0);

pub fn init(x: f64, y: f64, z: f64) Self {
    return .{
    .x = x,
    .y = y,
    .z = z,
    };
}

pub inline fn negate(self: Self) Self {
    return Self{ .x = -self.x, .y = -self.y, .z = -self.z };
}

pub inline fn add(self: Self, other: Self) Self {
    return Self{ .x = self.x + other.x, .y = self.y + other.y, .z = self.z + other.z };
}

pub inline fn subtract(self: Self, other: Self) Self {
    return Self{ .x = self.x - other.x, .y = self.y - other.y, .z = self.z - other.z };
}

pub inline fn multiply(self: Self, scalar: f64) Self {
    return Self{ .x = self.x * scalar, .y = self.y * scalar, .z = self.z * scalar };
}

pub inline fn divide(self: Self, scalar: f64) Self {
    return Self{ .x = self.x / scalar, .y = self.y / scalar, .z = self.z / scalar };
}

pub inline fn lengthSquared(self: Self) f64 {
    return self.x * self.x + self.y * self.y + self.z * self.z;
}

pub inline fn length(self: Self) f64 {
    return std.math.sqrt(self.lengthSquared());
}

pub inline fn dot(self: Self, other: Self) f64 {
    return self.x * other.x + self.y * other.y + self.z * other.z;
}

pub inline fn cross(self: Self, other: Self) Self {
    return Self{
    .x = self.y * other.z - self.z * other.y,
    .y = self.z * other.x - self.x * other.z,
    .z = self.x * other.y - self.y * other.x,
    };
}

pub inline fn unit_vector(self: Self) Self {
    return self.divide(self.length());
}

pub inline fn random_unit_vector() Self {
    return random_in_unit_sphere().unit_vector();
}

pub inline fn random_in_unit_sphere() Self {
    while (true) {
        const p = Self.random_with_limits(-1, 1);
        if (p.lengthSquared() < 1) {
            return p;
        }
    }
}

pub inline fn random_on_hemisphere(normal: Vec3) Vec3 {
    const on_unit_sphere = random_unit_vector();
    if (on_unit_sphere.dot(normal) > 0.0) {
        return on_unit_sphere;
    }
    return on_unit_sphere.negate();
}

pub inline fn random() Self {
    return Self{
    .x = rt.random_double(),
    .y = rt.random_double(),
    .z = rt.random_double(),
    };
}

pub inline fn random_with_limits(min: f64, max: f64) Self {
    return Self{
    .x = rt.random_double_limited(min, max),
    .y = rt.random_double_limited(min, max),
    .z = rt.random_double_limited(min, max),
    };
}
