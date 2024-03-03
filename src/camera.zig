const std = @import("std");
const rt = @import("rtweekend.zig");

const Self = @This();
pub const Camera = Self;

const image_width: i32 = 1600;
const aspect_ratio = 16.0 / 9.0;

const image_height: i32 = @max(1, @as(i32, @as(f64, image_width) / aspect_ratio));
const camera_center = rt.Point3.init(0, 0, 0);

const focal_length = 1.0;
const viewport_height = 2.0;
const viewport_width = viewport_height * (@as(f64, image_width) / @as(f64, image_height));

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

    canvas: rt.Canvas,
    renderer: rt.Renderer,

pub fn init(allocator: std.mem.Allocator) !Self {
    const renderer: rt.Renderer = try rt.Renderer.init("Zigray", rt.Camera.image_width,
    rt.Camera.image_height, allocator);
    const canvas = try rt.Canvas.init(rt.Camera.image_width, rt.Camera.image_height, allocator);
    return Self { .canvas = canvas, .renderer = renderer };
}

pub fn deinit(self: *Self) void {
    defer self.canvas.deinit();
    defer self.renderer.deinit();
}

pub fn is_filming(self: *Self) bool {
    return self.renderer.isRunning();
}

pub fn ray_colour(ray: rt.Ray, world: rt.Hittable) rt.Colour {
    var rec: rt.Hittable.HitRecord = .{.p = .{ .x = 0, .y = 0, .z = 0}, .is_front = false, .normal = .{ .x = 0, .y = 0, .z = 0}, .t = 0, };
    if (world.hit(ray, rt.Interval.init(0, rt.INFINITY), &rec)) {
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
            const xf: f64 = @floatFromInt(x);
            const yf: f64 = @floatFromInt(y);

            const pixel_center = pixel00_loc
            .add(pixel_delta_u.multiply(xf))
            .add(pixel_delta_v.multiply(yf));
            const ray_direction = pixel_center.subtract(camera_center);
            const ray = rt.Ray { .origin = camera_center, .direction = ray_direction };

            const pixel_colour = ray_colour(ray, scene.asHittable());

            const X:i32 = @intCast(x);
            const Y:i32 = @intCast(y);

            self.canvas.setPixelWithColour(X, Y, pixel_colour);
        }
    }
    self.renderer.render(self.canvas);
}