const std = @import("std");
const rand = std.crypto.random;

const Renderer = @import("renderer.zig").Renderer;
const Canvas = @import("canvas.zig").Canvas;

const image_width: i32 = 800;
const image_height: i32 = 800;

pub fn main() !void {

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const renderer: Renderer = try Renderer.init("Zigray", image_width, image_height, allocator);
    defer renderer.deinit();

    const canvas = try Canvas.init(image_width, image_height, allocator);
    defer canvas.deinit();
    
    while (renderer.isRunning()) {
        update(canvas);
        renderer.render(canvas);
    }
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

