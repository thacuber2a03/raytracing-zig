const std = @import("std");

const Hittable = @import("../Hittable.zig");
const rtw = @import("../root.zig");
const vec = rtw.vec;

const List = @This();

objects: std.ArrayList(Hittable) = .empty,

pub const init: List = .{};

pub fn deinit(self: *List, gpa: std.mem.Allocator) void {
    self.objects.deinit(gpa);
}

fn hit(ptr: *const anyopaque, r: rtw.Ray, ray_t: rtw.Interval) ?Hittable.Record {
    const self: *const List = @ptrCast(@alignCast(ptr));

    var rec: ?Hittable.Record = null;
    var closest_so_far = ray_t.max;

    for (self.objects.items) |o|
        if (o.hit(r, .init(ray_t.min, closest_so_far))) |res| {
            rec = res;
            closest_so_far = res.t;
        };

    return rec;
}

pub fn hittable(self: *List) Hittable {
    return .{ .ptr = self, .vtable = .{ .hit = hit } };
}
