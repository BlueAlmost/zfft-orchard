const std = @import("std");
const math = std.math;
const print = std.debug.print;
const Complex = std.math.Complex;

const cp_dit_bf = @import("butterflies").cp_dit_bf;
const cp_dit_bf_0 = @import("butterflies").cp_dit_bf_0;
const cp_dit_bf_pi4 = @import("butterflies").cp_dit_bf_pi4;

const ct_dit_bf2 = @import("butterflies").ct_dit_bf2;
const ct_dit_bf2_0 = @import("butterflies").ct_dit_bf2_0;
const ct_dit_bf2_pi4 = @import("butterflies").ct_dit_bf2_pi4;
const ct_dit_bf2_pi2 = @import("butterflies").ct_dit_bf2_pi2;
const ct_dit_bf2_3pi4 = @import("butterflies").ct_dit_bf2_3pi4;

const ct_dif_bf2 = @import("butterflies").ct_dif_bf2;
const ct_dif_bf2_0 = @import("butterflies").ct_dif_bf2_0;

const mr_dit_bf4_0 = @import("butterflies").mr_dit_bf4_0;
const mr_dit_bf4_1 = @import("butterflies").mr_dit_bf4_1;
const mr_dit_bf4 = @import("butterflies").mr_dit_bf4;

const sr_dit_bf4 = @import("butterflies").sr_dit_bf4;
const sr_dit_bf4_pi4 = @import("butterflies").sr_dit_bf4_pi4;
const sr_dit_bf4_0 = @import("butterflies").sr_dit_bf4_0;

pub fn main() !void {
    print("\n\ttesting butterflies:\n", .{});

    try test_cp_dit_bf();
    try test_cp_dit_bf_0();
    try test_cp_dit_bf_pi4();

    try test_ct_dit_bf2();
    try test_ct_dit_bf2_0();
    try test_ct_dit_bf2_pi4();
    try test_ct_dit_bf2_pi2();
    try test_ct_dit_bf2_3pi4();

    try test_ct_dif_bf2();
    try test_ct_dif_bf2_0();

    try test_mr_dit_bf4_0();
    try test_mr_dit_bf4_1();
    try test_mr_dit_bf4();

    try test_sr_dit_bf4();
    try test_sr_dit_bf4_pi4();
    try test_sr_dit_bf4_0();
}

// Butterflies for the conjugate pair FFT -----------------------------------
pub fn test_cp_dit_bf() !void {
    print("\t\t cp_dit_bf \t\t...", .{});

    const eps = 1e-3;
    inline for (.{ f32, f64 }) |T| {
        const C = Complex(T);

        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer arena.deinit();

        const allocator = arena.allocator();

        var out = try allocator.alloc(C, 4);

        out[0] = C.init(1.1, 2.2);
        out[1] = C.init(0.3, 1.2);
        out[2] = C.init(2.1, -2.2);
        out[3] = C.init(5.2, -0.3);

        var w = C.init(4.2, -1.7);
        var s: usize = 1;

        cp_dit_bf(C, s, out.ptr, w);

        try std.testing.expectApproxEqAbs(@as(T, 28.53), out[0].re, eps);
        try std.testing.expectApproxEqAbs(@as(T, -3.03), out[0].im, eps);

        try std.testing.expectApproxEqAbs(@as(T, -20.09), out[1].re, eps);
        try std.testing.expectApproxEqAbs(@as(T, 18.47), out[1].im, eps);

        try std.testing.expectApproxEqAbs(@as(T, -26.33), out[2].re, eps);
        try std.testing.expectApproxEqAbs(@as(T, 7.43), out[2].im, eps);

        try std.testing.expectApproxEqAbs(@as(T, 20.69), out[3].re, eps);
        try std.testing.expectApproxEqAbs(@as(T, -16.07), out[3].im, eps);
    }
    print("\tpassed.\n", .{});
}

pub fn test_cp_dit_bf_pi4() !void {
    print("\t\t cp_dit_bf_pi4 \t\t...", .{});

    const eps = 1e-3;
    inline for (.{ f32, f64 }) |T| {
        const C = Complex(T);

        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer arena.deinit();

        const allocator = arena.allocator();

        var out = try allocator.alloc(C, 4);

        out[0] = C.init(1.1, 2.2);
        out[1] = C.init(0.3, 1.2);
        out[2] = C.init(2.1, -2.2);
        out[3] = C.init(5.2, -0.3);

        var s: usize = 1;

        cp_dit_bf_pi4(C, s, out.ptr);

        try std.testing.expectApproxEqAbs(@as(T, 4.9183766), out[0].re, eps);
        try std.testing.expectApproxEqAbs(@as(T, 2.6242640), out[0].im, eps);

        try std.testing.expectApproxEqAbs(@as(T, -6.2053823), out[1].re, eps);
        try std.testing.expectApproxEqAbs(@as(T, 5.1597979), out[1].im, eps);

        try std.testing.expectApproxEqAbs(@as(T, -2.7183766), out[2].re, eps);
        try std.testing.expectApproxEqAbs(@as(T, 1.7757359), out[2].im, eps);

        try std.testing.expectApproxEqAbs(@as(T, 6.8053823), out[3].re, eps);
        try std.testing.expectApproxEqAbs(@as(T, -2.7597979), out[3].im, eps);
    }
    print("\tpassed.\n", .{});
}

pub fn test_cp_dit_bf_0() !void {
    print("\t\t cp_dit_bf_0 \t\t...", .{});

    const eps = 1e-3;
    inline for (.{ f32, f64 }) |T| {
        const C = Complex(T);
        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);

        defer arena.deinit();

        const allocator = arena.allocator();

        var out = try allocator.alloc(C, 4);

        out[0] = C.init(1.1, 2.2);
        out[1] = C.init(0.3, 1.2);
        out[2] = C.init(2.1, -2.2);
        out[3] = C.init(5.2, -0.3);

        var s: usize = 1;

        cp_dit_bf_0(C, s, out.ptr);

        try std.testing.expectApproxEqAbs(@as(T, 8.4), out[0].re, eps);
        try std.testing.expectApproxEqAbs(@as(T, -0.3), out[0].im, eps);

        try std.testing.expectApproxEqAbs(@as(T, -1.6), out[1].re, eps);
        try std.testing.expectApproxEqAbs(@as(T, 4.3), out[1].im, eps);

        try std.testing.expectApproxEqAbs(@as(T, -6.2), out[2].re, eps);
        try std.testing.expectApproxEqAbs(@as(T, 4.7), out[2].im, eps);

        try std.testing.expectApproxEqAbs(@as(T, 2.2), out[3].re, eps);
        try std.testing.expectApproxEqAbs(@as(T, -1.9), out[3].im, eps);
    }
    print("\tpassed.\n", .{});
}

// Butterflies for the radix 2 Cooley-Tukey FFT ------------------------------
pub fn test_ct_dit_bf2_0() !void {
    print("\t\t ct_dit_bf2_0 \t\t...", .{});

    const eps = 1e-3;
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    inline for (.{ f32, f64 }) |T| {
        const C: type = Complex(T);

        var in = try allocator.alloc(C, 4);
        var out = try allocator.alloc(C, 4);

        var si: usize = 1;
        var so: usize = 3;

        in[0] = C.init(1.1, 2.2);
        in[1] = C.init(0.3, 1.2);
        in[2] = C.init(2.1, -2.2);
        in[3] = C.init(5.2, 0.3);

        ct_dit_bf2_0(C, so, si, out.ptr, in.ptr);

        try std.testing.expectApproxEqAbs(@as(T, 1.4), out[0].re, eps);
        try std.testing.expectApproxEqAbs(@as(T, 3.4), out[0].im, eps);

        try std.testing.expectApproxEqAbs(@as(T, 0.8), out[3].re, eps);
        try std.testing.expectApproxEqAbs(@as(T, 1.0), out[3].im, eps);
    }
    print("\tpassed.\n", .{});
}

pub fn test_ct_dit_bf2_pi4() !void {
    print("\t\t ct_dit_bf2_pi4 \t...", .{});

    const eps = 1e-3;
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    inline for (.{ f32, f64 }) |T| {
        const C: type = Complex(T);

        var out = try allocator.alloc(C, 4);

        var s: usize = 1;

        out[0] = C.init(1.1, 2.2);
        out[1] = C.init(0.3, 1.2);
        out[2] = C.init(2.1, -2.2);
        out[3] = C.init(5.2, 0.3);

        ct_dit_bf2_pi4(C, s, out.ptr);

        try std.testing.expectApproxEqAbs(@as(T, 2.160660), out[0].re, eps);
        try std.testing.expectApproxEqAbs(@as(T, 2.836396), out[0].im, eps);

        try std.testing.expectApproxEqAbs(@as(T, 0.039339), out[1].re, eps);
        try std.testing.expectApproxEqAbs(@as(T, 1.563604), out[1].im, eps);
    }
    print("\tpassed.\n", .{});
}

pub fn test_ct_dit_bf2_3pi4() !void {
    print("\t\t ct_dit_bf2_3pi4 \t...", .{});

    const eps = 1e-3;

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    inline for (.{ f32, f64 }) |T| {
        const C: type = Complex(T);

        var out = try allocator.alloc(C, 4);

        var s: usize = 1;

        out[0] = C.init(1.1, 2.2);
        out[1] = C.init(0.3, 1.2);
        out[2] = C.init(2.1, -2.2);
        out[3] = C.init(5.2, 0.3);

        ct_dit_bf2_3pi4(C, s, out.ptr);

        try std.testing.expectApproxEqAbs(@as(T, 1.736396), out[0].re, eps);
        try std.testing.expectApproxEqAbs(@as(T, 1.139339), out[0].im, eps);

        try std.testing.expectApproxEqAbs(@as(T, 0.463603), out[1].re, eps);
        try std.testing.expectApproxEqAbs(@as(T, 3.260660), out[1].im, eps);
    }
    print("\tpassed.\n", .{});
}

pub fn test_ct_dit_bf2_pi2() !void {
    print("\t\t ct_dit_bf2_pi2 \t...", .{});

    const eps = 1e-3;

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    inline for (.{ f32, f64 }) |T| {
        const C: type = Complex(T);

        var out = try allocator.alloc(C, 4);

        var s: usize = 1;

        out[0] = C.init(1.1, 2.2);
        out[1] = C.init(0.3, 1.2);
        out[2] = C.init(2.1, -2.2);
        out[3] = C.init(5.2, 0.3);

        ct_dit_bf2_pi2(C, s, out.ptr);

        try std.testing.expectApproxEqAbs(@as(T, 2.3), out[0].re, eps);
        try std.testing.expectApproxEqAbs(@as(T, 1.9), out[0].im, eps);

        try std.testing.expectApproxEqAbs(@as(T, -0.1), out[1].re, eps);
        try std.testing.expectApproxEqAbs(@as(T, 2.5), out[1].im, eps);
    }
    print("\tpassed.\n", .{});
}

pub fn test_ct_dit_bf2() !void {
    print("\t\t ct_dit_bf2 \t\t...", .{});

    const eps = 1e-3;

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    inline for (.{ f32, f64 }) |T| {
        const C: type = Complex(T);

        var w: C = undefined;
        w.re = @cos(math.pi * @as(T, @floatFromInt(-2)) / @as(T, @floatFromInt(16)));
        w.im = @sin(math.pi * @as(T, @floatFromInt(-2)) / @as(T, @floatFromInt(16)));

        var out = try allocator.alloc(C, 4);

        var s: usize = 1;

        out[0] = C.init(1.1, 2.2);
        out[1] = C.init(0.3, 1.2);
        out[2] = C.init(2.1, -2.2);
        out[3] = C.init(5.2, 0.3);

        ct_dit_bf2(C, s, out.ptr, w);

        try std.testing.expectApproxEqAbs(@as(T, 1.83638), out[0].re, eps);
        try std.testing.expectApproxEqAbs(@as(T, 3.19385), out[0].im, eps);

        try std.testing.expectApproxEqAbs(@as(T, 0.363616), out[1].re, eps);
        try std.testing.expectApproxEqAbs(@as(T, 1.206149), out[1].im, eps);
    }
    print("\tpassed.\n", .{});
}

pub fn test_ct_dif_bf2_0() !void {
    print("\t\t ct_dif_bf2_0 \t\t...", .{});

    const eps = 1e-3;

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    inline for (.{ f32, f64 }) |T| {
        const C: type = Complex(T);

        var in = try allocator.alloc(C, 4);
        var out = try allocator.alloc(C, 4);

        var si: usize = 1;
        var so: usize = 3;

        in[0] = C.init(1.1, 2.2);
        in[1] = C.init(0.3, 1.2);
        in[2] = C.init(2.1, -2.2);
        in[3] = C.init(5.2, 0.3);

        ct_dif_bf2_0(C, so, si, out.ptr, in.ptr);

        try std.testing.expectApproxEqAbs(@as(T, 1.4), out[0].re, eps);
        try std.testing.expectApproxEqAbs(@as(T, 3.4), out[0].im, eps);

        try std.testing.expectApproxEqAbs(@as(T, 0.8), out[3].re, eps);
        try std.testing.expectApproxEqAbs(@as(T, 1.0), out[3].im, eps);
    }
    print("\tpassed.\n", .{});
}

pub fn test_ct_dif_bf2() !void {
    print("\t\t ct_dif_bf2 \t\t...", .{});

    const eps = 1e-3;

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    inline for (.{ f32, f64 }) |T| {
        const C: type = Complex(T);

        var w: C = undefined;
        w.re = @cos(math.pi * @as(T, @floatFromInt(-2)) / @as(T, @floatFromInt(16)));
        w.im = @sin(math.pi * @as(T, @floatFromInt(-2)) / @as(T, @floatFromInt(16)));

        var out = try allocator.alloc(C, 4);

        var s: usize = 1;

        out[0] = C.init(1.1, 2.2);
        out[1] = C.init(0.3, 1.2);
        out[2] = C.init(2.1, -2.2);
        out[3] = C.init(5.2, 0.3);

        ct_dif_bf2(C, s, out.ptr, w);

        try std.testing.expectApproxEqAbs(@as(T, 1.4), out[0].re, eps);
        try std.testing.expectApproxEqAbs(@as(T, 3.4), out[0].im, eps);

        try std.testing.expectApproxEqAbs(@as(T, 1.121787), out[1].re, eps);
        try std.testing.expectApproxEqAbs(@as(T, 0.617733), out[1].im, eps);
    }
    print("\tpassed.\n", .{});
}

// Radix-4 butterflies for the mixed radix FFT -----------------------------------

pub fn test_mr_dit_bf4_0() !void {
    print("\t\t mr_dit_bf4_0 \t\t...", .{});

    const eps = 1e-3;

    inline for (.{ f32, f64 }) |T| {
        const C = Complex(T);

        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer arena.deinit();

        const allocator = arena.allocator();

        var in = try allocator.alloc(C, 4);
        var out = try allocator.alloc(C, 7);

        in[0] = C.init(2.3, 2.6);
        in[1] = C.init(-0.1, 1.1);
        in[2] = C.init(2.0, -3.0);
        in[3] = C.init(-2.1, -1.3);

        out[0] = C.init(0.0, 0.0);
        out[1] = C.init(0.0, 0.0);
        out[2] = C.init(0.0, 0.0);
        out[3] = C.init(0.0, 0.0);
        out[4] = C.init(0.0, 0.0);
        out[5] = C.init(0.0, 0.0);

        var si: usize = 1;
        var so: usize = 2;

        mr_dit_bf4_0(C, so, si, out.ptr, in.ptr);

        try std.testing.expectApproxEqAbs(@as(T, 2.1), out[0].re, eps);
        try std.testing.expectApproxEqAbs(@as(T, -0.6), out[0].im, eps);

        try std.testing.expectApproxEqAbs(@as(T, 2.7), out[2].re, eps);
        try std.testing.expectApproxEqAbs(@as(T, 3.6), out[2].im, eps);

        try std.testing.expectApproxEqAbs(@as(T, 6.5), out[4].re, eps);
        try std.testing.expectApproxEqAbs(@as(T, -0.2), out[4].im, eps);

        try std.testing.expectApproxEqAbs(@as(T, -2.1), out[6].re, eps);
        try std.testing.expectApproxEqAbs(@as(T, 7.6), out[6].im, eps);
    }
    print("\tpassed.\n", .{});
}

pub fn test_mr_dit_bf4_1() !void {
    print("\t\t mr_dit_bf4_1 \t\t...", .{});

    const eps = 1e-3;

    inline for (.{ f32, f64 }) |T| {
        const C = Complex(T);

        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer arena.deinit();

        const allocator = arena.allocator();

        var out = try allocator.alloc(C, 4);

        out[0] = C.init(1.1, 2.2);
        out[1] = C.init(-0.3, 1.2);
        out[2] = C.init(2.1, -2.2);
        out[3] = C.init(5.2, 0.3);

        var s: usize = 1;

        mr_dit_bf4_1(C, s, out.ptr);

        try std.testing.expectApproxEqAbs(@as(T, -3.928427), out[0].re, eps);
        try std.testing.expectApproxEqAbs(@as(T, -2.728427), out[0].im, eps);

        try std.testing.expectApproxEqAbs(@as(T, 8.249747), out[1].re, eps);
        try std.testing.expectApproxEqAbs(@as(T, 0.198780), out[1].im, eps);

        try std.testing.expectApproxEqAbs(@as(T, 1.728247), out[2].re, eps);
        try std.testing.expectApproxEqAbs(@as(T, 2.928427), out[2].im, eps);

        try std.testing.expectApproxEqAbs(@as(T, -1.649747), out[3].re, eps);
        try std.testing.expectApproxEqAbs(@as(T, 8.401219), out[3].im, eps);
    }
    print("\tpassed.\n", .{});
}

pub fn test_mr_dit_bf4() !void {
    print("\t\t mr_dit_bf4 \t\t...", .{});

    const eps = 1e-3;

    inline for (.{ f32, f64 }) |T| {
        const C = Complex(T);

        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer arena.deinit();

        const allocator = arena.allocator();

        const w1 = C.init(-0.1234, 0.5678);
        const w2 = C.init(0.2233, -0.4455);
        const w3 = C.init(-0.3333, 0.4444);

        var out = try allocator.alloc(C, 4);

        out[0] = C.init(1.1, 2.2);
        out[1] = C.init(-0.3, 1.2);
        out[2] = C.init(2.1, -2.2);
        out[3] = C.init(5.2, 0.3);

        var s: usize = 1;

        mr_dit_bf4(C, s, out.ptr, w1, w2, w3);

        try std.testing.expectApproxEqAbs(@as(T, -1.92198), out[0].re, eps);
        try std.testing.expectApproxEqAbs(@as(T, 2.66566), out[0].im, eps);

        try std.testing.expectApproxEqAbs(@as(T, -0.91814), out[1].re, eps);
        try std.testing.expectApproxEqAbs(@as(T, 2.40467), out[1].im, eps);

        try std.testing.expectApproxEqAbs(@as(T, 3.09965), out[2].re, eps);
        try std.testing.expectApproxEqAbs(@as(T, -1.1193), out[2].im, eps);

        try std.testing.expectApproxEqAbs(@as(T, 4.14048), out[3].re, eps);
        try std.testing.expectApproxEqAbs(@as(T, 4.84895), out[3].im, eps);
    }
    print("\tpassed.\n", .{});
}

pub fn test_sr_dit_bf4() !void {
    print("\t\t sr_dit_bf4 \t\t...", .{});

    const eps = 1e-3;

    inline for (.{ f32, f64 }) |T| {
        const C = Complex(T);

        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer arena.deinit();

        const allocator = arena.allocator();

        var out = try allocator.alloc(C, 4);

        out[0] = C.init(1.1, 2.2);
        out[1] = C.init(-0.3, 1.2);
        out[2] = C.init(2.1, -2.2);
        out[3] = C.init(5.2, 0.3);

        var w1 = C.init(4.2, -1.7);
        var w3 = C.init(-2.1, -1.3);
        var s: usize = 1;

        sr_dit_bf4(C, s, out.ptr, w1, w3);

        try std.testing.expectApproxEqAbs(@as(T, -4.35), out[0].re, eps);
        try std.testing.expectApproxEqAbs(@as(T, -18.00), out[0].im, eps);

        try std.testing.expectApproxEqAbs(@as(T, -5.72), out[1].re, eps);
        try std.testing.expectApproxEqAbs(@as(T, -14.41), out[1].im, eps);

        try std.testing.expectApproxEqAbs(@as(T, 6.55), out[2].re, eps);
        try std.testing.expectApproxEqAbs(@as(T, 22.4), out[2].im, eps);

        try std.testing.expectApproxEqAbs(@as(T, 5.12), out[3].re, eps);
        try std.testing.expectApproxEqAbs(@as(T, 16.81), out[3].im, eps);
    }
    print("\tpassed.\n", .{});
}

pub fn test_sr_dit_bf4_pi4() !void {
    print("\t\t sr_dit_bf4_pi4 \t...", .{});

    const eps = 1e-3;

    inline for (.{ f32, f64 }) |T| {
        const C = Complex(T);

        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer arena.deinit();

        const allocator = arena.allocator();

        var out = try allocator.alloc(C, 4);

        out[0] = C.init(1.1, 2.2);
        out[1] = C.init(-0.3, 1.2);
        out[2] = C.init(2.1, -2.2);
        out[3] = C.init(5.2, -0.3);

        var s: usize = 1;

        sr_dit_bf4_pi4(C, s, out.ptr);

        try std.testing.expectApproxEqAbs(@as(T, -2.859797), out[0].re, eps);
        try std.testing.expectApproxEqAbs(@as(T, -4.305382), out[0].im, eps);

        try std.testing.expectApproxEqAbs(@as(T, 0.124264), out[1].re, eps);
        try std.testing.expectApproxEqAbs(@as(T, -2.618476), out[1].im, eps);

        try std.testing.expectApproxEqAbs(@as(T, 5.05979), out[2].re, eps);
        try std.testing.expectApproxEqAbs(@as(T, 8.70538), out[2].im, eps);

        try std.testing.expectApproxEqAbs(@as(T, -0.72426), out[3].re, eps);
        try std.testing.expectApproxEqAbs(@as(T, 5.01837), out[3].im, eps);
    }
    print("\tpassed.\n", .{});
}

pub fn test_sr_dit_bf4_0() !void {
    print("\t\t sr_dit_bf4_0 \t\t...", .{});

    const eps = 1e-3;

    inline for (.{ f32, f64 }) |T| {
        const C = Complex(T);

        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer arena.deinit();

        const allocator = arena.allocator();

        var out = try allocator.alloc(C, 4);

        out[0] = C.init(1.1, 2.2);
        out[1] = C.init(-0.3, 1.2);
        out[2] = C.init(2.1, -2.2);
        out[3] = C.init(5.2, -0.3);

        var s: usize = 1;

        sr_dit_bf4_0(C, s, out.ptr);

        try std.testing.expectApproxEqAbs(@as(T, 8.4), out[0].re, eps);
        try std.testing.expectApproxEqAbs(@as(T, -0.30), out[0].im, eps);

        try std.testing.expectApproxEqAbs(@as(T, -2.2), out[1].re, eps);
        try std.testing.expectApproxEqAbs(@as(T, 4.3), out[1].im, eps);

        try std.testing.expectApproxEqAbs(@as(T, -6.2), out[2].re, eps);
        try std.testing.expectApproxEqAbs(@as(T, 4.7), out[2].im, eps);

        try std.testing.expectApproxEqAbs(@as(T, 1.6), out[3].re, eps);
        try std.testing.expectApproxEqAbs(@as(T, -1.9), out[3].im, eps);
    }
    print("\tpassed.\n", .{});
}
