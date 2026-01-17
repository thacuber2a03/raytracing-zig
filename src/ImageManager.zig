const std = @import("std");

const zigimg = @import("zigimg");
const Image = zigimg.Image;

const ImageManager = @This();

images: std.StringArrayHashMapUnmanaged(Image),
gpa: std.mem.Allocator,

pub fn init(gpa: std.mem.Allocator) ImageManager {
    return .{ .gpa = gpa, .images = .empty };
}

pub fn addImageFromFilepath(self: *ImageManager, filepath: []const u8) !*Image {
    var read_buffer: [zigimg.io.DEFAULT_BUFFER_SIZE]u8 = undefined;
    const gop = try self.images.getOrPut(self.gpa, filepath);
    if (gop.found_existing) return gop.value_ptr;
    gop.key_ptr.* = filepath;
    gop.value_ptr.* = try .fromFilePath(self.gpa, filepath, &read_buffer);
    return gop.value_ptr;
}

pub fn deinit(self: *ImageManager) void {
    var it = self.images.iterator();
    while (it.next()) |e| e.value_ptr.deinit(self.gpa);
    self.images.deinit(self.gpa);
    self.gpa = undefined;
}
