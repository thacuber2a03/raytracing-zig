const std = @import("std");

const rtw = @import("root.zig");

const Interval = @This();

min: rtw.Real,
max: rtw.Real,

pub const default: Interval = .empty;

pub fn init(min: rtw.Real, max: rtw.Real) Interval {
    return .{ .min = min, .max = max };
}

pub fn size(self: Interval) rtw.Real {
    return self.max - self.min;
}

pub fn contains(self: Interval, x: rtw.Real) bool {
    return self.min <= x and x <= self.max;
}

pub fn surrounds(self: Interval, x: rtw.Real) bool {
    return self.min < x and x < self.max;
}

pub fn clamp(self: Interval, x: rtw.Real) rtw.Real {
    return std.math.clamp(x, self.min, self.max);
}

pub const empty: Interval = .init(std.math.inf(), -std.math.inf());
pub const universe: Interval = .init(-std.math.inf(), std.math.inf());
