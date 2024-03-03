const std = @import("std");

pub usingnamespace @import("vector.zig");
pub usingnamespace @import("colour.zig");
pub usingnamespace @import("canvas.zig");
pub usingnamespace @import("renderer.zig");
pub usingnamespace @import("ray.zig");
pub usingnamespace @import("scene.zig");
pub usingnamespace @import("camera.zig");

pub const INFINITY = std.math.inf(f64);
pub const PI = std.math.pi;

// Utility Functions

pub inline fn degrees_to_radians(degrees: f64) f64 {
    return degrees * PI / 180.0;
}

pub const Interval = struct {
    min: f64 = INFINITY,
    max: f64 = -INFINITY,

    pub const EMPTY = Interval {};
    pub const UNIVERSE = Interval { .min = -INFINITY, .max = INFINITY };

    pub fn init(min: f64, max: f64) Interval {
        return Interval { .min = min, .max = max };
    }

    pub fn contains(self: Interval, x: f64) bool {
        return self.min <= x and x <= self.max;
    }

    pub fn surrounds(self: Interval, x: f64) bool {
        return self.min < x and x < self.max;
    }
};
