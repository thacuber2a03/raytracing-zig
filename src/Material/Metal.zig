const std = @import("std");

const rtw = @import("../root.zig");
const vec = rtw.vec;

const Material = @import("../Material.zig");
const Hittable = @import("../Hittable.zig");

const Metal = @This();

albedo: rtw.Color,
fuzz: rtw.Real,

pub fn init(albedo: rtw.Color, fuzz: rtw.Real) Metal {
    return .{ .albedo = albedo, .fuzz = @max(fuzz, 1) };
}

pub fn create(gpa: std.mem.Allocator, albedo: rtw.Color, fuzz: rtw.Real) !Material {
    const mat = try gpa.create(Metal);
    mat.* = .init(albedo, fuzz);
    return mat.material();
}

fn scatter(
    ptr: *anyopaque,
    r_in: rtw.Ray,
    rec: *const Hittable.Record,
    rnd: std.Random,
) ?Material.Scatter {
    const self: *const Metal = @ptrCast(@alignCast(ptr));
    const reflected = vec.reflect(r_in.direction, rec.normal);

    const perturbed = vec.unit(reflected) +
        vec.scale(vec.randomUnitVector(rnd), self.fuzz);

    return if (vec.dot(perturbed, rec.normal) > 0) .{
        .attenuation = self.albedo,
        .scattered = .initAtTime(rec.p, perturbed, r_in.time),
    } else null;
}

pub fn material(self: *Metal) Material {
    return .{ .ptr = self, .vtable = .{ .scatter = scatter } };
}
