const std = @import("std");
const math = std.math;
const print = std.debug.print;
const Complex = std.math.Complex;

const fft = @import("FFT").Sr_dit_bi_G.fft;

var Bench = @import("Bench").Bench().init();

const verify_only = @import("build_options").verify_only;

pub fn main() !void {
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

            var w1 = try allocator.alloc(C, nfft / 4);
            var w3 = try allocator.alloc(C, nfft / 4);

            const twiddle_sr_init = @import("Twiddles").Std.sr_init;

            twiddle_sr_init(C, nfft / 4, nfft, w1.ptr, w3.ptr);

            const in_place = false;

            const args = .{ .C = C, .nfft = nfft, .w1 = w1.ptr, .w3 = w3.ptr, .yp = y.ptr, .xp = x.ptr };

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
