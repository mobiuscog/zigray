const std = @import("std");
const rt = @import("rtweekend.zig");

const Self = @This();
pub const Camera = Self;

    canvas: rt.Canvas,
    renderer: rt.Renderer,
    context: Context,

pub fn init(image_width: u16, aspect_ratio: f64, samples_per_pixel: u8, allocator: std.mem.Allocator) !Self {

    const context = Context.init(image_width, aspect_ratio, samples_per_pixel);
    const renderer: rt.Renderer = try rt.Renderer.init("Zigray", context.image_width, context.image_height, allocator);
    const canvas = try rt.Canvas.init(context.image_width, context.image_height, allocator);
    return Self {
        .canvas = canvas,
        .renderer = renderer,
        .context = context,
    };
}

const Context = struct {
    image_width: u16,
    image_height: u16,
    aspect_ratio: f64,
    samples_per_pixel: u8,
    camera_center: rt.Point3,
    focal_length: f64,
    viewport_height: f64,
    viewport_width: f64,
    viewport_u: rt.Vec3,
    viewport_v: rt.Vec3,
    pixel_delta_u: rt.Vec3,
    pixel_delta_v: rt.Vec3,
    viewport_upper_left: rt.Vec3,
    pixel00_loc: rt.Vec3,

    fn init(image_width: u16, aspect_ratio: f64, samples_per_pixel: u8) Context {

        const image_height: u16 = @max(1, @as(u16, @intFromFloat(@as(f64, @floatFromInt(image_width)) / aspect_ratio)));
        const camera_center = rt.Point3.ORIGIN;

        const focal_length = 1.0;
        const viewport_height = 2.0;
        const viewport_width = viewport_height * (@as(f64, @floatFromInt(image_width)) / @as(f64, @floatFromInt(image_height)));

    // Calculate the vectors across the horizontal and down the vertical viewport edges.
        const viewport_u = rt.Vec3.init(viewport_width, 0, 0);
        const viewport_v = rt.Vec3.init(0, -viewport_height, 0);

    // Calculate the horizontal and vertical delta vectors from pixel to pixel.
        const pixel_delta_u = viewport_u.divide(@floatFromInt(image_width));
        const pixel_delta_v = viewport_v.divide(@floatFromInt(image_height));

    // Calculate the location of the upper left pixel.
        const viewport_upper_left = camera_center
        .subtract(rt.Vec3.init(0, 0, focal_length))
        .subtract(viewport_u.divide(2.0))
        .subtract(viewport_v.divide(2.0));
        const pixel00_loc = viewport_upper_left.add(pixel_delta_u.add(pixel_delta_v).multiply(0.5));

        return Context {
            .image_width = image_width,
            .image_height = image_height,
            .aspect_ratio = aspect_ratio,
            .samples_per_pixel = samples_per_pixel,
            .camera_center = camera_center,
            .focal_length = focal_length,
            .viewport_height = viewport_height,
            .viewport_width = viewport_width,
            .viewport_u = viewport_u,
            .viewport_v = viewport_v,
            .pixel_delta_u = pixel_delta_u,
            .pixel_delta_v = pixel_delta_v,
            .viewport_upper_left = viewport_upper_left,
            .pixel00_loc = pixel00_loc,
        };
    }
};

pub fn deinit(self: *Self) void {
    defer self.canvas.deinit();
    defer self.renderer.deinit();
}

pub fn is_filming(self: *Self) bool {
    return self.renderer.isRunning();
}

pub fn ray_colour(ray: rt.Ray, world: rt.Hittable) rt.Colour {
    var rec: rt.Hittable.HitRecord = .{.p = .{ .x = 0, .y = 0, .z = 0}, .is_front = false, .normal = .{ .x = 0, .y = 0, .z = 0}, .t = 0, };
    if (world.hit(ray, rt.Interval(f64).init(0, rt.INFINITY), &rec)) {
        const tmp = rec.normal.add(.{ .x = 1.0, .y = 1.0, .z = 1.0,}).multiply(0.5);
        return rt.Colour {.r = tmp.x, .g = tmp.y, .b = tmp.z};
    }

    const unit_direction = ray.direction.unit_vector();
    const a = 0.5 * (unit_direction.y + 1.0);
    return rt.Colour.WHITE.multiply(1.0 - a).add(rt.Colour.SKY.multiply(a));
}

pub fn update(self: *Self, scene: *rt.Scene) void {
    for (0..self.canvas.height) |y| {
        for (0..self.canvas.width) |x| {

            var pixel_colour = rt.BLACK;
            const object = scene.asHittable();
            for (0..self.context.samples_per_pixel) |_| {
                const ray = self.get_ray(@intCast(x), @intCast(y));
                pixel_colour = pixel_colour.add(ray_colour(ray, object));
            }

            self.canvas.setPixelWithColour(@intCast(x), @intCast(y), pixel_colour, self.context.samples_per_pixel);
        }
    }
    self.renderer.render(self.canvas);
}

fn get_ray(self: *Self, i: i32, j: i32) rt.Ray {
    const pixel_center = self.context.pixel00_loc.add(self.context.pixel_delta_u.multiply(@floatFromInt(i)))
                        .add(self.context.pixel_delta_v.multiply(@floatFromInt(j)));
    const pixel_sample = pixel_center.add(self.pixel_sample_square());

    const ray_origin = self.context.camera_center;
    const ray_direction = pixel_sample.subtract(ray_origin);

    return rt.Ray { .origin = ray_origin, .direction = ray_direction };
}

fn pixel_sample_square(self: *Self) rt.Vec3 {
    const px = -0.5 + rt.random_double();
    const py = -0.5 + rt.random_double();
    return self.context.pixel_delta_u.multiply(px).add(self.context.pixel_delta_v.multiply(py));
}