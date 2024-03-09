const std = @import("std");
const assert = std.debug.assert;

pub usingnamespace @import("vector.zig");
pub usingnamespace @import("colour.zig");
pub usingnamespace @import("canvas.zig");
pub usingnamespace @import("renderer.zig");
pub usingnamespace @import("ray.zig");
pub usingnamespace @import("scene.zig");
pub usingnamespace @import("camera.zig");

pub const INFINITY = std.math.inf(f64);
pub const PI = std.math.pi;

var rand_impl = std.rand.DefaultPrng.init(42);
const num = rand_impl.random().int(i32);


// Utility Functions

pub inline fn degrees_to_radians(degrees: f64) f64 {
    return degrees * PI / 180.0;
}

pub inline fn random_double() f64 {
    // Returns a random real in [0,1).
    return rand_impl.random().float(f64);
}

pub inline fn random_double_limited(min: f64, max: f64) f64 {
    // Returns a random real in [min,max).
    return min + (max-min)*random_double();
}

pub fn Interval(comptime T: type) type {
    assert(@typeInfo(T) == .Float or @typeInfo(T) == .ComptimeFloat
        or @typeInfo(T) == .Int or @typeInfo(T) == .ComptimeInt);

    return struct {
        min: T = INFINITY,
        max: T = -INFINITY,

        pub const EMPTY = Interval(T) {};
        pub const UNIVERSE = Interval(T) { .min = -INFINITY, .max = INFINITY };

        pub fn init(min: T, max: T) Interval(T) {
            return Interval(T) { .min = min, .max = max };
        }

        pub fn contains(self: Interval(T), x: T) bool {
            return self.min <= x and x <= self.max;
        }

        pub fn surrounds(self: Interval(T), x: T) bool {
            return self.min < x and x < self.max;
        }

        pub inline fn clamp(self: Interval(T), value: T) T {
            return @min(self.max, @max(self.min, value));
        }
    };
}


