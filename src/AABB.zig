const std = @import("std");

const rtw = @import("root.zig");

const Interval = @import("Interval.zig");

const AABB = @This();

x: Interval,
y: Interval,
z: Interval,

pub const default: AABB = .empty;

pub fn init(x: Interval, y: Interval, z: Interval) AABB {
    return .{ .x = x, .y = y, .z = z };
}

pub fn fromPoints(a: rtw.Point3, b: rtw.Point3) AABB {
    return .{
        .x = if (a[0] <= b[0]) .init(a[0], b[0]) else .init(b[0], a[0]),
        .y = if (a[1] <= b[1]) .init(a[1], b[1]) else .init(b[1], a[1]),
        .z = if (a[2] <= b[2]) .init(a[2], b[2]) else .init(b[2], a[2]),
    };
}

pub fn fromBoxes(a: AABB, b: AABB) AABB {
    return .{
        .x = .fromIntervals(a.x, b.x),
        .y = .fromIntervals(a.y, b.y),
        .z = .fromIntervals(a.z, b.z),
    };
}

pub fn axisInterval(self: *const AABB, n: usize) Interval {
    return switch (n) {
        1 => self.y,
        2 => self.z,
        else => self.x,
    };
}

pub fn hit(self: *const AABB, r: rtw.Ray, ray_t: Interval) bool {
    const origin: [3]rtw.Real = r.origin;
    const direction: [3]rtw.Real = r.direction;

    var t: Interval = ray_t;

    for (0..3) |axis| {
        const ax = self.axisInterval(axis);
        const adinv = 1.0 / direction[axis];

        var t0 = (ax.min - origin[axis]) * adinv;
        var t1 = (ax.max - origin[axis]) * adinv;

        if (t0 > t1) std.mem.swap(rtw.Real, &t0, &t1);

        if (t0 > t.min) t.min = t0;
        if (t1 < t.max) t.max = t1;

        if (t.max <= t.min) return false;
    }

    return true;
}

pub fn longestAxis(self: *const AABB) usize {
    if (self.x.size() > self.y.size()) {
        return if (self.x.size() > self.z.size()) 0 else 2;
    } else {
        return if (self.y.size() > self.z.size()) 1 else 2;
    }
}

pub const empty: AABB = .init(.empty, .empty, .empty);
pub const universe: AABB = .init(.universe, .universe, .universe);
