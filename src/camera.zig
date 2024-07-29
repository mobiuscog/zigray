const std = @import("std");
const rt = @import("rtweekend.zig");

const Self = @This();
pub const Camera = Self;

var finished = false;

pub const State = enum {
INITIALISED,
RUNNING,
FINISHED,
};

canvas: rt.Canvas,
renderer: rt.Renderer,
state: State = State.INITIALISED,
context: Context,
runners: [256] bool,
runners_len: u8,

pub fn init(image_width: u16, aspect_ratio: f64, samples_per_pixel: u8, allocator: std.mem.Allocator) !Self {

    const context = Context.init(image_width, aspect_ratio, samples_per_pixel);
    const renderer: rt.Renderer = try rt.Renderer.init("Zigray", context.image_width, context.image_height, allocator);
    const canvas = try rt.Canvas.init(context.image_width, context.image_height, allocator);
    return Self {
    .canvas = canvas,
    .renderer = renderer,
    .context = context,
    .runners = [_] bool { false } ** 256,
    .runners_len = 0,
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
        const direction = rt.Vec3.random_on_hemisphere(rec.normal);
        return ray_colour(rt.Ray { .origin = rec.p, .direction = direction, }, world).multiply(0.5);
    }

    const unit_direction = ray.direction.unit_vector();
    const a = 0.5 * (unit_direction.y + 1.0);
    return rt.Colour.WHITE.multiply(1.0 - a).add(rt.Colour.SKY.multiply(a));
}

pub fn update(self: *Self, scene: *rt.Scene) void {
    switch (self.state) {
    State.INITIALISED => {
        const total_thread_count: usize = std.Thread.getCpuCount() catch unreachable;
        var thread_count: u8 = @truncate(total_thread_count);
        thread_count -= 1;
        self.runners_len = thread_count;
        const hittable = scene.asHittable();
        for (0..thread_count) |i| {
            const index: u8 = @intCast(i);
            const thread = std.Thread.spawn(.{}, Self.process, .{self, thread_count, index, hittable}) catch { continue; };
            thread.detach();
            self.runners[index] = true;
        }
        self.state = State.RUNNING;
    },
    State.RUNNING => {
        var i: u8 = 0;
        var still_running = self.runners_len;
        while (i < self.runners_len) : (i += 1) {
            if (self.runners[i]) {
                break;
            }
            still_running -= 1;
        }
        if (still_running == 0) {
            self.state = State.FINISHED;
        }
    },
    State.FINISHED => {
        if (finished == false) {
            std.debug.print("Finished !", .{});
            finished = true;
        }
    },
    }
    self.renderer.render(self.canvas, self.state);
}

fn process(self: *Self, offset: u8, thread_index: u8, object: rt.Hittable) !void {
    var y: u16 = thread_index;

    while (y < self.canvas.height) : (y += offset){
        var x: u16 = 0;
        while (x < self.canvas.width) : (x += 1) {
            var pixel_colour = rt.BLACK;
            for (0..self.context.samples_per_pixel) |_| {
                const ray = self.get_ray(x, y);
                pixel_colour = pixel_colour.add(ray_colour(ray, object));
            }

            self.canvas.setPixelWithColour(x, y, pixel_colour, self.context.samples_per_pixel);
        }
    }
    self.runners[thread_index] = false;
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