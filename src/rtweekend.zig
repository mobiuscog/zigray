const std = @import("std");

pub usingnamespace @import("vector.zig");
pub usingnamespace @import("vector.zig");
pub usingnamespace @import("colour.zig");
pub usingnamespace @import("canvas.zig");
pub usingnamespace @import("renderer.zig");
pub usingnamespace @import("ray.zig");
pub usingnamespace @import("scene.zig");

pub const INFINITY = std.math.inf(f64);
pub const PI = std.math.pi;

// Utility Functions

pub inline fn degrees_to_radians(degrees: f64) f64 {
    return degrees * PI / 180.0;
}
