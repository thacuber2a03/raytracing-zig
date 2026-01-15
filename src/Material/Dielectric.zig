const std = @import("std");

const rtw = @import("../root.zig");
const vec = rtw.vec;

const Material = @import("../Material.zig");
const Hittable = @import("../Hittable.zig");

const Dielectric = @This();

refraction_index: rtw.Real,

pub fn init(refraction_index: rtw.Real) Dielectric {
    return .{ .refraction_index = refraction_index };
}

pub fn create(gpa: std.mem.Allocator, refraction_index: rtw.Real) !Material {
    const mat = try gpa.create(Dielectric);
    mat.* = .init(refraction_index);
    return mat.material();
}

fn scatter(
    ptr: *anyopaque,
    r_in: rtw.Ray,
    rec: *const Hittable.Record,
    rnd: std.Random,
) ?Material.Scatter {
    const self: *const Dielectric = @ptrCast(@alignCast(ptr));

    const ri = if (rec.front_face) 1 / self.refraction_index else self.refraction_index;

    const unit_dir = vec.unit(r_in.direction);
    const cos_theta = @min(vec.dot(-unit_dir, rec.normal), 1);
    const sin_theta = std.math.sqrt(1 - cos_theta * cos_theta);

    const cannot_refract = ri * sin_theta > 1;

    const direction = if (cannot_refract or reflectance(cos_theta, ri) > rnd.float(rtw.Real))
        vec.reflect(unit_dir, rec.normal)
    else
        vec.refract(unit_dir, rec.normal, ri);

    return .{
        .attenuation = .{ 1, 1, 1 },
        .scattered = .initAtTime(rec.p, direction, r_in.time),
    };
}

fn reflectance(cosine: rtw.Real, refraction_index: rtw.Real) rtw.Real {
    var r0 = (1 - refraction_index) / (1 + refraction_index);
    r0 = r0 * r0;
    return r0 + (1 - r0) * std.math.pow(rtw.Real, 1 - cosine, 5);
}

pub fn material(self: *Dielectric) Material {
    return .{ .ptr = self, .vtable = .{ .scatter = scatter } };
}
