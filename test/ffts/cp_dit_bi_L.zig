const std = @import("std");
const math = std.math;
const print = std.debug.print;
const Complex = std.math.Complex;

const fft = @import("FFT").Cp_dit_bi_L.fft;

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

            const twiddle_init = @import("Twiddles").Std.init;
            const cp_input_lut_init = @import("LUT").CP.input_lut_init;
            const sr_sched_lut_init = @import("LUT").SR.sched_lut_init;
            const jacobsthal = @import("LUT").SR.jacobsthal;

            var cp_input_lut: [*]usize = undefined;
            var sr_sched_off: [*]usize = undefined;
            var sr_sched_cnt: [*]usize = undefined;

            var w = try allocator.alloc(C, nfft / 4);
            twiddle_init(C, nfft / 4, nfft, w.ptr);

            var cp_input_lut_slice = try allocator.alloc(usize, nfft / 2);
            cp_input_lut = cp_input_lut_slice.ptr;
            cp_input_lut_init(usize, nfft, cp_input_lut);

            var sr_sched_cnt_slice = try allocator.alloc(usize, m);
            sr_sched_cnt = sr_sched_cnt_slice.ptr;

            var sr_sched_off_slice = try allocator.alloc(usize, jacobsthal(math.log2(nfft)) + 1);
            sr_sched_off = sr_sched_off_slice.ptr;

            sr_sched_lut_init(usize, nfft, sr_sched_cnt, sr_sched_off);

            const in_place = false;

            const args = .{
                .C = C,
                .nfft = nfft,
                .w = w.ptr,
                .yp = y.ptr,
                .xp = x.ptr,
                .cp_input_lut = cp_input_lut,
                .sr_sched_off = sr_sched_off,
                .sr_sched_cnt = sr_sched_cnt,
            };

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
