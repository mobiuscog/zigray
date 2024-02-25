const std = @import("std");

pub const Canvas = struct {
    width: u32,
    height: u32,
    buffer: []u8,
    allocator: std.mem.Allocator,

    pub fn init(width: u32, height: u32, allocator: std.mem.Allocator) !Canvas {
        const allocated = try allocator.alloc(u8, width * height * 4);
        return Canvas { .width = width, .height = height, .buffer = allocated, .allocator = allocator };
    }

    pub fn deinit(self: Canvas) void {
        self.allocator.free(self.buffer);
    }

    pub fn setPixel(self: Canvas, x: i32, y: i32, red: u8, green: u8, blue: u8) void {
        const X: u32 = @intCast(x);
        const Y: u32 = @intCast(y);
        const offset = (Y * self.width * 4) + X * 4;
        self.buffer[offset] = red;
        self.buffer[offset+1] = green;
        self.buffer[offset+2] = blue;
        self.buffer[offset+3] = 255;
    }

    pub fn getBuffer(self: Canvas) [*]u8 {
        return self.buffer.ptr;
    }
};
