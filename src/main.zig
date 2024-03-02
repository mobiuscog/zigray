const std = @import("std");
const rand = std.crypto.random;

const rt = @import("rtweekend.zig");

const PixelContext = struct {
    pixel_delta_u: rt.Vec3,
    pixel_delta_v: rt.Vec3,
    pixel00_loc: rt.Vec3,
    camera_center: rt.Vec3,
};

pub fn main() !void {

    const image_width: i32 = 1600;
    const aspect_ratio = 16.0 / 9.0;

    const image_height: i32 = @max(1, @as(i32, @as(f64, image_width) / aspect_ratio));

    // World
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer std.debug.assert(gpa.deinit() == .ok);

    var scene = try rt.Scene.init(allocator);
    defer scene.deinit();
    var sphere = rt.Sphere.init(rt.Point3.init(0, 0, -1), 0.5);
    try scene.add(sphere.asHittable());
    var sphere2 = rt.Sphere.init(rt.Point3.init(0, -100.5, -1),100);
    try scene.add(sphere2.asHittable());

    // Camera
    const focal_length = 1.0;
    const viewport_height = 2.0;
    const viewport_width = viewport_height * (@as(f64, image_width) / @as(f64, image_height));
    const camera_center = rt.Point3.init(0, 0, 0);

    // Calculate the vectors across the horizontal and down the vertical viewport edges.
    const viewport_u = rt.Vec3.init(viewport_width, 0, 0);
    const viewport_v = rt.Vec3.init(0, -viewport_height, 0);


    // Calculate the horizontal and vertical delta vectors from pixel to pixel.
    const pixel_delta_u = viewport_u.divide(image_width);
    const pixel_delta_v = viewport_v.divide(image_height);

    // Calculate the location of the upper left pixel.
    const viewport_upper_left = camera_center
        .subtract(rt.Vec3.init(0, 0, focal_length))
        .subtract(viewport_u.divide(2.0))
        .subtract(viewport_v.divide(2.0));
    const pixel00_loc = viewport_upper_left.add(pixel_delta_u.add(pixel_delta_v).multiply(0.5));

    const pixel_context = PixelContext {
        .pixel00_loc = pixel00_loc,
        .pixel_delta_u = pixel_delta_u,
        .pixel_delta_v = pixel_delta_v,
        .camera_center = camera_center,
    };

    const renderer: rt.Renderer = try rt.Renderer.init("Zigray", image_width, image_height, allocator);
    defer renderer.deinit();

    const canvas = try rt.Canvas.init(image_width, image_height, allocator);
    defer canvas.deinit();

    while (renderer.isRunning()) {
        update(canvas, &scene, pixel_context);
        renderer.render(canvas);
    }
}

fn update(canvas: rt.Canvas, scene: *rt.Scene, context: PixelContext) void {
    for (0..canvas.height) |y| {
        for (0..canvas.width) |x| {
            const xf: f64 = @floatFromInt(x);
            const yf: f64 = @floatFromInt(y);

            const pixel_center = context.pixel00_loc
                .add(context.pixel_delta_u.multiply(xf))
                .add(context.pixel_delta_v.multiply(yf));
            const ray_direction = pixel_center.subtract(context.camera_center);
            const ray = rt.Ray { .origin = context.camera_center, .direction = ray_direction };

            const pixel_colour = ray.colour(scene.asHittable());

            const X:i32 = @intCast(x);
            const Y:i32 = @intCast(y);

            canvas.setPixelWithColour(X, Y, pixel_colour);
        }
    }
}

