const std = @import("std");

const rtw = @import("raytracing");
const vec = rtw.vec;
const Sphere = rtw.Hittable.Sphere;
const Lambertian = rtw.Material.Lambertian;
const Metal = rtw.Material.Metal;
const Dielectric = rtw.Material.Dielectric;

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const arena = init.arena.allocator();

    var seed: [@sizeOf(u64)]u8 = undefined;
    io.random(&seed);
    var prng = std.Random.DefaultPrng.init(@bitCast(seed));
    const rnd = prng.random();

    var world: rtw.Hittable.List = .init;

    const ground_material: rtw.Material = try Lambertian.create(arena, .{ 0.5, 0.5, 0.5 });
    try world.objects.append(arena, try Sphere.create(arena, .{ 0, -1000, 0 }, 1000, ground_material));

    for (0..22) |i| {
        const a = @as(rtw.Real, @floatFromInt(i)) - 11;
        for (0..22) |j| {
            const b = @as(rtw.Real, @floatFromInt(j)) - 11;

            const choose_mat = rnd.float(rtw.Real);
            const center: rtw.Point3 = .{
                a + 0.9 * rnd.float(rtw.Real),
                0.2,
                b + 0.9 * rnd.float(rtw.Real),
            };

            if (vec.length(center - rtw.Point3{ 4, 0.2, 0 }) > 0.9) {
                try world.objects.append(arena, res: {
                    if (choose_mat < 0.8) {
                        const mat = try Lambertian.create(arena, vec.random(rnd) * vec.random(rnd));
                        const center2 = center + rtw.Vec3{ 0, rtw.randomRange(rnd, 0, 0.5), 0 };
                        break :res try Sphere.createMoving(arena, center, center2, 0.2, mat);
                    } else {
                        const mat = try if (choose_mat < 0.95)
                            Metal.create(arena, vec.randomRange(rnd, 0.5, 1), rtw.randomRange(rnd, 0, 0.5))
                        else
                            Dielectric.create(arena, 1.5);

                        break :res try Sphere.create(arena, center, 0.2, mat);
                    }
                });
            }
        }
    }

    try world.objects.append(arena, try Sphere.create(
        arena,
        .{ 0, 1, 0 },
        1,
        try Dielectric.create(arena, 1.5),
    ));

    try world.objects.append(arena, try Sphere.create(
        arena,
        .{ -4, 1, 0 },
        1,
        try Lambertian.create(arena, .{ 0.4, 0.2, 0.1 }),
    ));

    try world.objects.append(arena, try Sphere.create(
        arena,
        .{ 4, 1, 0 },
        1,
        try Metal.create(arena, .{ 0.7, 0.6, 0.5 }, 0),
    ));

    var cam: rtw.Camera = .init(.{
        .aspect_ratio = 16.0 / 9.0,
        .image_width = 1200,
        .samples_per_pixel = 500,
        .max_depth = 50,

        .vfov = 20,
        .lookfrom = .{ 13, 2, 3 },
        .lookat = vec.zero,
        .vup = .{ 0, 1, 0 },

        .defocus_angle = 0.6,
        .focus_dist = 10.0,
    });

    try cam.render(init.gpa, init.io, world.hittable(), .{
        .cores_amt = try std.Thread.getCpuCount() - 1,
    });
}
