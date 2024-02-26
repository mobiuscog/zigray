const std = @import("std");
const rand = std.crypto.random;

const Renderer = @import("renderer.zig").Renderer;
const Canvas = @import("canvas.zig").Canvas;
const Colour = @import("colour.zig").Colour;
const Colours = @import("colour.zig").Colours;
const Ray = @import("ray.zig").Ray;
const Vec3 = @import("vector.zig").Vec3;
const Point3 = Vec3;


pub fn ray_colour(ray: Ray) Colour {
    const unit_direction = ray.direction.unit_vector();
    const a = 0.5 * (unit_direction.y + 1.0);
    return Colours.WHITE.multiply(1.0 - a).add(Colours.SKY.multiply(a));
}

const PixelContext = struct {
    pixel_delta_u: Vec3,
    pixel_delta_v: Vec3,
    pixel00_loc: Vec3,
    camera_center: Vec3,
};

pub fn main() !void {

    const image_width: i32 = 1600;
    const aspect_ratio = 16.0 / 9.0;

    const image_height: i32 = @max(1, @as(i32, @as(f64, image_width) / aspect_ratio));

    // Camera
    const focal_length = 1.0;
    const viewport_height = 2.0;
    const viewport_width = viewport_height * (@as(f64, image_width) / @as(f64, image_height));
    const camera_center = Point3 { .x = 0, .y = 0, .z = 0, };

    // Calculate the vectors across the horizontal and down the vertical viewport edges.
    const viewport_u = Vec3 { .x = viewport_width, .y = 0, .z = 0, };
    const viewport_v = Vec3 { .x = 0, .y = -viewport_height, .z = 0, };


    // Calculate the horizontal and vertical delta vectors from pixel to pixel.
    const pixel_delta_u = viewport_u.divide(image_width);
    const pixel_delta_v = viewport_v.divide(image_height);

    // Calculate the location of the upper left pixel.
    const viewport_upper_left = camera_center
        .subtract(Vec3 {.x = 0, .y = 0, .z = focal_length})
        .subtract(viewport_u.divide(2.0))
        .subtract(viewport_v.divide(2.0));
    const pixel00_loc = viewport_upper_left.add(pixel_delta_u.add(pixel_delta_v).multiply(0.5));

    const pixel_context = PixelContext {
        .pixel00_loc = pixel00_loc,
        .pixel_delta_u = pixel_delta_u,
        .pixel_delta_v = pixel_delta_v,
        .camera_center = camera_center,
    };

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const renderer: Renderer = try Renderer.init("Zigray", image_width, image_height, allocator);
    defer renderer.deinit();

    const canvas = try Canvas.init(image_width, image_height, allocator);
    defer canvas.deinit();

    while (renderer.isRunning()) {
        update(canvas, pixel_context);
        renderer.render(canvas);
    }
}

fn update(canvas: Canvas, context: PixelContext) void {
    for (0..canvas.height) |y| {
        for (0..canvas.width) |x| {
            const xf: f64 = @floatFromInt(x);
            const yf: f64 = @floatFromInt(y);

            const pixel_center = context.pixel00_loc
                .add(context.pixel_delta_u.multiply(xf))
                .add(context.pixel_delta_v.multiply(yf));
            const ray_direction = pixel_center.subtract(context.camera_center);
            const ray = Ray { .origin = context.camera_center, .direction = ray_direction };
            const pixel_colour = ray_colour(ray);

            const X:i32 = @intCast(x);
            const Y:i32 = @intCast(y);

            canvas.setPixelWithColour(X, Y, pixel_colour);
        }
    }
}

