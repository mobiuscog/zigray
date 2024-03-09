const std = @import("std");

const raylib = @cImport(@cInclude("raylib.h"));

const Canvas = @import("rtweekend.zig").Canvas;
const State = @import("rtweekend.zig").Camera.State;
const Colour = @import("rtweekend.zig").Colour;

const Self = @This();
pub const Renderer = Self;

width: u32,
height: u32,
texture: raylib.Texture2D,
allocator: std.mem.Allocator,

pub fn init(name: [*:0]const u8, width: u32, height: u32, allocator: std.mem.Allocator) !Self {
    raylib.SetConfigFlags(raylib.FLAG_WINDOW_RESIZABLE);
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

pub fn render(self: Self, canvas: Canvas, state: State) void {
    raylib.BeginDrawing();
    defer raylib.EndDrawing();

    raylib.ClearBackground(raylib.BLACK);

    raylib.UpdateTexture(self.texture, canvas.getBuffer());

    raylib.DrawTexture(self.texture, 0,0, raylib.WHITE);

    switch (state) {
    State.INITIALISED => {},
    State.RUNNING => {
        const x: i32 = @intCast(self.width / 2);
        const y: i32 = @intCast(self.height / 2);
        const width: i32 = @divTrunc(raylib.MeasureText("Rendering...", 64), 2);
        const r_width: f32 = @floatFromInt(width * 2 + 120);
        const r_height: f32 = 120.0;
        const r_x: f32 = @floatFromInt(x - width - 60);
        const r_y: f32 = @floatFromInt(y - 27);
        const black = raylib.ColorAlpha(raylib.BLACK, 0.5);
        raylib.DrawRectangleRounded(raylib.Rectangle {.height = r_height, .width = r_width, .x = r_x, .y = r_y},
        0.3, 8, black);
        raylib.DrawText("Rendering...", x - width, y, 64, raylib.RED);
    },
    State.FINISHED => {},
    }
}