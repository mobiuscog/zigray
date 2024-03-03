const std = @import("std");

const raylib = @import("raylib");

const Canvas = @import("rtweekend.zig").Canvas;

const Self = @This();
pub const Renderer = Self;

width: u32,
height: u32,
texture: raylib.Texture2D,
allocator: std.mem.Allocator,

pub fn init(name: [*:0]const u8, width: u32, height: u32, allocator: std.mem.Allocator) !Self {
    raylib.SetConfigFlags(raylib.ConfigFlags{ .FLAG_WINDOW_RESIZABLE = true });
    raylib.InitWindow(@intCast(width), @intCast(height), name);
    raylib.SetTargetFPS(60);
    var origin: raylib.Image = raylib.GenImageColor(@intCast(width), @intCast(height), raylib.RED);
    raylib.ImageFormat(&origin, 7);
    const texture: raylib.Texture2D = raylib.LoadTextureFromImage(origin);
    raylib.UnloadImage(origin);
    return Renderer {
        .width = width,
        .height = height,
        .texture = texture,
        .allocator = allocator,
    };
}

pub fn deinit(self: Self) void {
    raylib.UnloadTexture(self.texture);
    raylib.CloseWindow();
}

pub fn isRunning(self: Self) bool {
    _ = self;
    return !raylib.WindowShouldClose();
}

pub fn createTexture() void {

}

pub fn render(self: Self, canvas: Canvas) void {
    raylib.BeginDrawing();
    defer raylib.EndDrawing();

    raylib.ClearBackground(raylib.BLACK);

    raylib.UpdateTexture(self.texture, canvas.getBuffer());

    raylib.DrawTexture(self.texture, 0,0, raylib.WHITE);
}