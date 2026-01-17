const std = @import("std");

const zigimg = @import("zigimg");

const ImageManager = @import("../ImageManager.zig");
const Interval = @import("../Interval.zig");
const rtw = @import("../root.zig");
const Texture = @import("../Texture.zig");

const Image = @This();

image: *zigimg.Image,

pub fn init(mgr: *ImageManager, filepath: []const u8) !Image {
    return .{
        .image = try mgr.addImageFromFilepath(filepath),
    };
}

pub fn pixelData(self: *const Image, x: usize, y: usize) rtw.Color {
    // this is such a hack, I know, but they already do format conversion,
    // and they don't supply it in any other way, so I'm not going to bother myself
    std.debug.assert(x < self.image.width and y < self.image.height);
    var color_it = self.image.iterator();
    color_it.current_index = y * self.image.width + x;
    if (color_it.next()) |c| return .{ c.r, c.g, c.b };
    return .{ 255, 0, 255 };
}

pub fn create(gpa: std.mem.Allocator, filepath: []const u8) !Texture {
    const tex = try gpa.create(Image);
    tex.* = .init(gpa, filepath);
    return tex.texture();
}

fn value(ptr: *const anyopaque, u: rtw.Real, v: rtw.Real, p: rtw.Point3) rtw.Color {
    _ = p;
    const self: *const Image = @ptrCast(@alignCast(ptr));
    if (self.image.width == 0 or self.image.height == 0) return .{ 0, 1, 1 };

    const uu = Interval.init(0, 1).clamp(u);
    // TODO: should I really reverse the texture?
    const vv = 1 - Interval.init(0, 1).clamp(v);

    const w = self.image.width;
    const h = self.image.height;

    const i: usize = @intFromFloat(uu * @as(rtw.Real, @floatFromInt(w - 1)));
    const j: usize = @intFromFloat(vv * @as(rtw.Real, @floatFromInt(h - 1)));

    return self.pixelData(i, j);
}

pub fn texture(c: *Image) Texture {
    return .{ .ptr = c, .vtable = .{ .value = value } };
}
