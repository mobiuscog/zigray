const std = @import("std");

const rt = @import("rtweekend.zig");
const Colour = rt.Colour;
const Interval = rt.Interval;

const Self = @This();
pub const Canvas = Self;

width: u32,
height: u32,
buffer: []u8,
allocator: std.mem.Allocator,

pub fn init(width: u32, height: u32, allocator: std.mem.Allocator) !Self {
    const allocated = try allocator.alloc(u8, width * height * 4);
    return Self { .width = width, .height = height, .buffer = allocated, .allocator = allocator };
}

pub fn deinit(self: Self) void {
    self.allocator.free(self.buffer);
}

pub fn setPixelWithColour(self: Self, x: i32, y: i32, colour: Colour, samples_per_pixel: u8) void {
    const X: u32 = @intCast(x);
    const Y: u32 = @intCast(y);

    const average_colour = colour.divide(@floatFromInt(samples_per_pixel));

    const intensity = Interval(f64).init(0.0, 0.9);

    const red: u8 = @intFromFloat(256 * intensity.clamp(average_colour.r));
    const green: u8 = @intFromFloat(256 * intensity.clamp(average_colour.g));
    const blue: u8 = @intFromFloat(256 * intensity.clamp(average_colour.b));
    const alpha: u8 = @intFromFloat(256 * intensity.clamp(average_colour.a));

    const offset = (Y * self.width * 4) + X * 4;
    self.buffer[offset] = red;
    self.buffer[offset+1] = green;
    self.buffer[offset+2] = blue;
    self.buffer[offset+3] = alpha;

}

pub fn getBuffer(self: Self) [*]u8 {
    return self.buffer.ptr;
}
