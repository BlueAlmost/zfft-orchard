const std = @import("std");
const math = std.math;
const print = std.debug.print;
const Complex = std.math.Complex;

const fft = @import("FFT").Reference.fft;

var Bench = @import("Bench").Bench().init();
const verify_only = @import("build_options").verify_only;

pub fn main() !void {
    try verify_actual_length8();
    try verify();
}

fn verify_actual_length8() !void {

    // this is a real verification of length 8 vector, comparing
    // to FFTW results for the fixed input vector

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    try Bench.setName(allocator, @src());

    print("\n\ttesting {s} reference fft (fixed vector, length 8): ... ", .{Bench.fft_name});

    const eps = 1e-5;

    const m: usize = 3;
    var nfft: usize = std.math.pow(usize, 2, m);

    inline for (.{ f32, f64 }) |T| {
        const C: type = Complex(T);

        // input x, output y arrays
        var x = try allocator.alloc(C, nfft);
        var y = try allocator.alloc(C, nfft);
        var x_ref = try allocator.alloc(C, nfft);
        var y_ref = try allocator.alloc(C, nfft);

        x_ref[0].re = 1.1;
        x_ref[1].re = -2.5;
        x_ref[2].re = 1.4;
        x_ref[3].re = 2.3;
        x_ref[4].re = -1.1;
        x_ref[5].re = -2.2;
        x_ref[6].re = 2.2;
        x_ref[7].re = 1.2;

        x_ref[0].im = -0.1;
        x_ref[1].im = -2.1;
        x_ref[2].im = 1.4;
        x_ref[3].im = 0.2;
        x_ref[4].im = 1.1;
        x_ref[5].im = -2.2;
        x_ref[6].im = -0.2;
        x_ref[7].im = -1.4;

        y_ref[0].re = 2.4;
        y_ref[1].re = 4.0121320343559645;
        y_ref[2].re = -6.700000000000001;
        y_ref[3].re = 2.7920310216782975;
        y_ref[4].re = 4.800000000000001;
        y_ref[5].re = 3.5878679656440355;
        y_ref[6].re = -0.49999999999999956;
        y_ref[7].re = -1.592031021678297;

        y_ref[0].im = -3.3000000000000007;
        y_ref[1].im = -2.0263455967290596;
        y_ref[2].im = 7.999999999999999;
        y_ref[3].im = -1.5050252531694173;
        y_ref[4].im = 7.700000000000001;
        y_ref[5].im = 1.2263455967290593;
        y_ref[6].im = -8.399999999999999;
        y_ref[7].im = -2.4949747468305836;

        // copy reference inputs for use as test input
        for (x_ref, 0..) |val, i| {
            x[i] = val;
        }

        fft(C, nfft, y.ptr, x.ptr, 1);

        for (y, 0..) |_, i| {
            try std.testing.expectApproxEqAbs(y[i].re, y_ref[i].re, eps);
            try std.testing.expectApproxEqAbs(y[i].im, y_ref[i].im, eps);
        }
    }
    print("passed.\n", .{});
}

fn verify() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    try Bench.setName(allocator, @src());

    inline for (.{ f32, f64 }) |T| {
        print("\n", .{});
        inline for (Bench.m, 0..) |m, i_m| {
            const C: type = Complex(T);

            // input x, output y arrays
            var nfft: usize = std.math.pow(usize, 2, m);
            var x = try allocator.alloc(C, nfft);
            var y = try allocator.alloc(C, nfft);
            var x_ref = try allocator.alloc(C, nfft);
            var y_ref = try allocator.alloc(C, nfft);
            Bench.gen_data(x_ref, x);

            // fft under test ------------------------------------------------------------
            const in_place = false;
            const args = .{ .C = C, .nfft = nfft, .yp = y.ptr, .xp = x.ptr, .stride = 1 };
            // ---------------------------------------------------------------------------

            if (verify_only) {
                try std.testing.expect(Bench.verify(C, in_place, nfft, y_ref, x_ref, fft, args) == true);
            } else {
                print("\t {s}\t", .{Bench.fft_name});
                try Bench.speedTest(C, in_place, i_m, x_ref, fft, args);
            }
        }
    }

    if (!verify_only) {
        try Bench.writeResult(allocator);
    }
}
