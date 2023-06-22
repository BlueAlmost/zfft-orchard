const std = @import("std");
const math = std.math;
const print = std.debug.print;
const Complex = std.math.Complex;

const Twiddles = @import("Twiddles");

pub fn main() !void {
    print("\n\ttesting twiddles:\n", .{});
    try test_twiddle_sr_init();
}

pub fn test_twiddle_sr_init() !void {
    print("\t\t Twiddle.Std.sr_init\t...", .{});

    const eps = 1e-3;

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    inline for (.{ f32, f64 }) |T| {
        const C: type = Complex(T);

        var N: usize = 32;
        var l: usize = 8;

        var w = try allocator.alloc(C, 8);
        var w3 = try allocator.alloc(C, 8);
        Twiddles.Std.sr_init(C, l, N, w.ptr, w3.ptr);

        // correct values
        var q = try allocator.alloc(C, 8);
        var q3 = try allocator.alloc(C, 8);

        q[0] = C.init(1.000000, -0.000000);
        q[1] = C.init(0.980785, -0.195090);
        q[2] = C.init(0.923880, -0.382683);
        q[3] = C.init(0.831470, -0.555570);
        q[4] = C.init(0.707107, -0.707107);
        q[5] = C.init(0.555570, -0.831470);
        q[6] = C.init(0.382683, -0.923880);
        q[7] = C.init(0.195090, -0.980785);

        q3[0] = C.init(1.000000, -0.000000);
        q3[1] = C.init(0.831470, -0.555570);
        q3[2] = C.init(0.382683, -0.923880);
        q3[3] = C.init(-0.195090, -0.980785);
        q3[4] = C.init(-0.707107, -0.707107);
        q3[5] = C.init(-0.980785, -0.195090);
        q3[6] = C.init(-0.923880, 0.382683);
        q3[7] = C.init(-0.555570, 0.831470);

        try std.testing.expectApproxEqAbs(q[0].re, w[0].re, eps);
        try std.testing.expectApproxEqAbs(q[0].im, w[0].im, eps);

        try std.testing.expectApproxEqAbs(q[1].re, w[1].re, eps);
        try std.testing.expectApproxEqAbs(q[1].im, w[1].im, eps);

        try std.testing.expectApproxEqAbs(q[2].re, w[2].re, eps);
        try std.testing.expectApproxEqAbs(q[2].im, w[2].im, eps);

        try std.testing.expectApproxEqAbs(q[3].re, w[3].re, eps);
        try std.testing.expectApproxEqAbs(q[3].im, w[3].im, eps);

        try std.testing.expectApproxEqAbs(q[4].re, w[4].re, eps);
        try std.testing.expectApproxEqAbs(q[4].im, w[4].im, eps);

        try std.testing.expectApproxEqAbs(q[5].re, w[5].re, eps);
        try std.testing.expectApproxEqAbs(q[5].im, w[5].im, eps);

        try std.testing.expectApproxEqAbs(q[6].re, w[6].re, eps);
        try std.testing.expectApproxEqAbs(q[6].im, w[6].im, eps);

        try std.testing.expectApproxEqAbs(q[7].re, w[7].re, eps);
        try std.testing.expectApproxEqAbs(q[7].im, w[7].im, eps);

        // w3 & q3 ........................................

        try std.testing.expectApproxEqAbs(q3[0].re, w3[0].re, eps);
        try std.testing.expectApproxEqAbs(q3[0].im, w3[0].im, eps);

        try std.testing.expectApproxEqAbs(q3[1].re, w3[1].re, eps);
        try std.testing.expectApproxEqAbs(q3[1].im, w3[1].im, eps);

        try std.testing.expectApproxEqAbs(q3[2].re, w3[2].re, eps);
        try std.testing.expectApproxEqAbs(q3[2].im, w3[2].im, eps);

        try std.testing.expectApproxEqAbs(q3[3].re, w3[3].re, eps);
        try std.testing.expectApproxEqAbs(q3[3].im, w3[3].im, eps);

        try std.testing.expectApproxEqAbs(q3[4].re, w3[4].re, eps);
        try std.testing.expectApproxEqAbs(q3[4].im, w3[4].im, eps);

        try std.testing.expectApproxEqAbs(q3[5].re, w3[5].re, eps);
        try std.testing.expectApproxEqAbs(q3[5].im, w3[5].im, eps);

        try std.testing.expectApproxEqAbs(q3[6].re, w3[6].re, eps);
        try std.testing.expectApproxEqAbs(q3[6].im, w3[6].im, eps);

        try std.testing.expectApproxEqAbs(q3[7].re, w3[7].re, eps);
        try std.testing.expectApproxEqAbs(q3[7].im, w3[7].im, eps);
    }

    print("\tpassed.\n", .{});
}
