const std = @import("std");

const rtw = @import("../root.zig");
const vec = rtw.vec;

const Material = @import("../Material.zig");
const Hittable = @import("../Hittable.zig");

const Lambertian = @This();

albedo: rtw.Color,

pub fn init(albedo: rtw.Color) Lambertian {
    return .{ .albedo = albedo };
}

pub fn create(gpa: std.mem.Allocator, albedo: rtw.Color) !Material {
    const mat = try gpa.create(Lambertian);
    mat.* = .init(albedo);
    return mat.material();
}

fn scatter(
    ptr: *anyopaque,
    r_in: rtw.Ray,
    rec: *const Hittable.Record,
    rnd: std.Random,
) ?Material.Scatter {
    const self: *const Lambertian = @ptrCast(@alignCast(ptr));
    var scatter_direction = rec.normal + vec.randomUnitVector(rnd);

    if (vec.nearZero(scatter_direction))
        scatter_direction = rec.normal;

    return .{
        .attenuation = self.albedo,
        .scattered = .initAtTime(rec.p, scatter_direction, r_in.time),
    };
}

pub fn material(self: *Lambertian) Material {
    return .{ .ptr = self, .vtable = .{ .scatter = scatter } };
}
