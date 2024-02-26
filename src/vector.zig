const std = @import("std");

// There are native optimised types for this in Zig, but they are recreated here for the sake of learning
pub const Vec3 = struct {
    x: f64,
    y: f64,
    z: f64,

    pub inline fn negate(self: Vec3) Vec3 {
        return Vec3 { .x = -self.x, .y = -self.y, .z = -self.z };
    }

    pub inline fn add(self: Vec3, other: Vec3) Vec3 {
        return Vec3 { .x = self.x + other.x, .y = self.y + other.y, .z = self.z + other.z };
    }

    pub inline fn subtract(self: Vec3, other: Vec3) Vec3 {
        return Vec3 { .x = self.x - other.x, .y = self.y - other.y, .z = self.z - other.z };
    }

    pub inline fn multiply(self: Vec3, scalar: f64) Vec3 {
        return Vec3 { .x = self.x * scalar, .y = self.y * scalar, .z = self.z * scalar };
    }

    pub inline fn divide(self: Vec3, scalar: f64) Vec3 {
        return Vec3 { .x = self.x / scalar, .y = self.y / scalar, .z = self.z / scalar };
    }

    pub inline fn lengthSquared(self: Vec3) f64 {
        return self.x * self.x + self.y * self.y + self.z * self.z;
    }

    pub inline fn length(self: Vec3) f64 {
        return std.math.sqrt(self.lengthSquared());
    }

    pub inline fn dot(self: Vec3, other: Vec3) f64 {
        return self.x * other.x + self.y * other.y + self.z * other.z;
    }   

    pub inline fn cross(self: Vec3, other: Vec3) Vec3 {
        return Vec3 {
            .x = self.y * other.z - self.z * other.y,
            .y = self.z * other.x - self.x * other.z,
            .z = self.x * other.y - self.y * other.x,
        };
    }

    pub fn unit_vector(self: Vec3) Vec3 {
        return self.divide(self.length());
    }
};