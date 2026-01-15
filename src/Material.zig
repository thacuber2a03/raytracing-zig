const std = @import("std");

const Hittable = @import("Hittable.zig");
pub const Lambertian = @import("Material/Lambertian.zig");
pub const Metal = @import("Material/Metal.zig");
pub const Dielectric = @import("Material/Dielectric.zig");
const rtw = @import("root.zig");

pub const Scatter = struct {
    attenuation: rtw.Color,
    scattered: rtw.Ray,
};

const Material = @This();

ptr: *anyopaque,
vtable: VTable,

pub const VTable = struct {
    scatter: *const fn (
        ptr: *anyopaque,
        r_in: rtw.Ray,
        rec: *const Hittable.Record,
        rnd: std.Random,
    ) ?Material.Scatter,
};

pub fn scatter(self: Material, r_in: rtw.Ray, rec: *const Hittable.Record, rnd: std.Random) ?Scatter {
    return self.vtable.scatter(self.ptr, r_in, rec, rnd);
}
