const std = @import("std");
const sqrt = std.math.sqrt;

const rtw = @import("root.zig");

pub const zero: rtw.Vec3 = .{ 0, 0, 0 };

pub fn splat(x: rtw.Real) rtw.Vec3 {
    return @splat(x);
}

pub fn scale(v: rtw.Vec3, t: rtw.Real) rtw.Vec3 {
    return v * splat(t);
}

pub fn div(v: rtw.Vec3, t: rtw.Real) rtw.Vec3 {
    return v / splat(t);
}

pub fn dot(a: rtw.Vec3, b: rtw.Vec3) rtw.Real {
    return @reduce(.Add, a * b);
}

pub fn lengthSquared(v: rtw.Vec3) rtw.Real {
    return dot(v, v);
}

pub fn length(v: rtw.Vec3) rtw.Real {
    return sqrt(lengthSquared(v));
}

pub fn unit(v: rtw.Vec3) rtw.Vec3 {
    const lensq = lengthSquared(v);
    const eps = std.math.floatEps(rtw.Real);
    if (std.math.approxEqAbs(rtw.Real, lensq, 0, eps))
        return v;
    return v / splat(length(v));
}

pub fn cross(a: rtw.Vec3, b: rtw.Vec3) rtw.Vec3 {
    const a_yzx = @shuffle(rtw.Real, a, zero, rtw.Vec3{ 1, 2, 0 });
    const a_zxy = @shuffle(rtw.Real, a, zero, rtw.Vec3{ 2, 0, 1 });

    const b_yzx = @shuffle(rtw.Real, b, zero, rtw.Vec3{ 1, 2, 0 });
    const b_zxy = @shuffle(rtw.Real, b, zero, rtw.Vec3{ 2, 0, 1 });

    return a_yzx * b_zxy - a_zxy * b_yzx;
}

pub fn nearZero(v: rtw.Vec3) bool {
    return std.math.approxEqAbs(rtw.Real, v[0], 0, 1e-8) and
        std.math.approxEqAbs(rtw.Real, v[1], 0, 1e-8) and
        std.math.approxEqAbs(rtw.Real, v[2], 0, 1e-8);
}

pub fn reflect(v: rtw.Vec3, n: rtw.Vec3) rtw.Vec3 {
    return v - scale(n, 2 * dot(v, n));
}

pub fn refract(uv: rtw.Vec3, n: rtw.Vec3, etai_over_etat: rtw.Real) rtw.Vec3 {
    const cos_theta = @min(dot(-uv, n), 1.0);
    const r_out_perp = scale(uv + scale(n, cos_theta), etai_over_etat);
    const r_out_parallel = scale(n, -sqrt(@abs(1 - lengthSquared(r_out_perp))));
    return r_out_perp + r_out_parallel;
}

pub fn random(rnd: std.Random) rtw.Vec3 {
    return .{ rnd.float(rtw.Real), rnd.float(rtw.Real), rnd.float(rtw.Real) };
}

pub fn randomRange(rnd: std.Random, min: rtw.Real, max: rtw.Real) rtw.Vec3 {
    return .{
        rtw.randomRange(rnd, min, max),
        rtw.randomRange(rnd, min, max),
        rtw.randomRange(rnd, min, max),
    };
}

pub fn randomUnitVector(rnd: std.Random) rtw.Vec3 {
    while (true) {
        const p = randomRange(rnd, -1, 1);
        const lensq = lengthSquared(p);
        if (1e-160 < lensq and lensq <= 1)
            return div(p, sqrt(lensq));
    }
}

pub fn randomOnHemisphere(rnd: std.Random, normal: rtw.Vec3) rtw.Vec3 {
    const on_unit_sphere = randomUnitVector(rnd);
    return if (dot(on_unit_sphere, normal) > 0)
        on_unit_sphere
    else
        -on_unit_sphere;
}

pub fn randomInUnitDisk(rnd: std.Random) rtw.Vec3 {
    while (true) {
        const p: rtw.Vec3 = .{ rtw.randomRange(rnd, -1, 1), rtw.randomRange(rnd, -1, 1), 0 };
        if (lengthSquared(p) < 1) return p;
    }
}
