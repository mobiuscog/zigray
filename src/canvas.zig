const std = @import("std");

const Colour = @import("rtweekend.zig").Colour;

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

pub fn setPixelWithColour(self: Self, x: i32, y: i32, colour: Colour) void {
    const X: u32 = @intCast(x);
    const Y: u32 = @intCast(y);

    const red: u8 = @intFromFloat(colour.r * 255);
    const green: u8 = @intFromFloat(colour.g * 255);
    const blue: u8 = @intFromFloat(colour.b * 255);
    const alpha: u8 = @intFromFloat(colour.a * 255);

    const offset = (Y * self.width * 4) + X * 4;
    self.buffer[offset] = red;
    self.buffer[offset+1] = green;
    self.buffer[offset+2] = blue;
    self.buffer[offset+3] = alpha;
}

pub fn getBuffer(self: Self) [*]u8 {
    return self.buffer.ptr;
}
