const std = @import("std");

const rt = @import("rtweekend.zig");

pub fn main() !void {

    // World
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer std.debug.assert(gpa.deinit() == .ok);

    var scene = try rt.Scene.init(allocator);
    defer scene.deinit();
    var sphere = rt.Sphere.init(rt.Point3.init(0, 0, -1), 0.5);
    try scene.add(sphere.asHittable());
    var sphere2 = rt.Sphere.init(rt.Point3.init(0, -100.5, -1), 100);
    try scene.add(sphere2.asHittable());

    var camera: rt.Camera = try rt.Camera.init(allocator);
    defer camera.deinit();

    while (camera.is_filming()) {
        camera.update(&scene);
    }
}
