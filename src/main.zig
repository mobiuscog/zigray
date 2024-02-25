const std = @import("std");
const rand = std.crypto.random;

const raylib = @import("raylib");

const Canvas = @import("canvas.zig").Canvas;

const image_width: i32 = 800;
const image_height: i32 = 800;

pub fn main() !void {

    initialiseRenderer("Zigray", image_width, image_height);
    defer closeRenderer();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const canvas = try Canvas.init(image_width, image_height, allocator);
    defer canvas.deinit();

    var origin: raylib.Image = raylib.GenImageColor(image_width, image_height, raylib.RED);
    raylib.ImageFormat(&origin, 7);
    const texture: raylib.Texture2D = raylib.LoadTextureFromImage(origin);
    raylib.UnloadImage(origin);
    defer raylib.UnloadTexture(texture);

    while (!raylib.WindowShouldClose()) {
        update(canvas);
        render(texture, canvas);
    }
}

fn initialiseRenderer(name: [*:0]const u8, width: i32, height: i32) void {
    raylib.SetConfigFlags(raylib.ConfigFlags{ .FLAG_WINDOW_RESIZABLE = true });
    raylib.InitWindow(width, height, name);
    raylib.SetTargetFPS(60);
}

fn closeRenderer() void {
    raylib.CloseWindow();
}

fn update(canvas: Canvas) void {
    for (0..image_height) |y| {
        for (0..image_width) |x| {

            const xf: f32 = @floatFromInt(x);
            const yf: f32 = @floatFromInt(y);

            const red: f32 = xf / (image_width - 1);
            const green: f32 = yf / (image_height - 1);
            const blue: f32 = 0;

            const red_u8: u8 = @intFromFloat(red * 255);
            const green_u8: u8 = @intFromFloat(green * 255);
            const blue_u8: u8 = @intFromFloat(blue * 255);

            const X:i32 = @intCast(x);
            const Y:i32 = @intCast(y);
            canvas.setPixel(X, Y, red_u8, green_u8, blue_u8);
        }
    }
}

fn render(texture: raylib.Texture2D, canvas: Canvas) void {
    raylib.BeginDrawing();
    defer raylib.EndDrawing();

    raylib.ClearBackground(raylib.BLACK);

    raylib.UpdateTexture(texture, canvas.getBuffer());

    raylib.DrawTexture(texture, 0,0, raylib.WHITE);
}
