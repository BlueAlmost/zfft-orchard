const std = @import("std");
const math = std.math;
const print = std.debug.print;
const Complex = std.math.Complex;

const mr_dit_bf4 = @import("butterflies").mr_dit_bf4;
const mr_dit_bf4_0 = @import("butterflies").mr_dit_bf4_0;
const mr_dit_bf4_1 = @import("butterflies").mr_dit_bf4_1;

const ct_dit_bf2_0 = @import("butterflies").ct_dit_bf2_0;

const get_twiddle = @import("Twiddles").Std.get;
const get_twiddle_mr = @import("Twiddles").Std.get_mr;

pub fn fft(comptime C: type, N: usize, w: [*]C, out: [*]C, in: [*]C) void {
    const log2_N: usize = math.log2(N);
    mr_dit_dr_P(C, w, in, out, 0, log2_N);
}

pub fn mr_dit_dr_P(comptime C: type, w: [*]C, in: [*]C, out: [*]C, s: usize, log2_N: usize) void {
    var l: usize = math.shl(usize, 1, log2_N - s);
    var stride: usize = math.shl(usize, 1, s);

    switch (l) {

        // last stage radix 2
        2 => {
            ct_dit_bf2_0(C, 1, stride, out, in);
        },

        // last stage radix 4
        4 => {
            mr_dit_bf4_0(C, 1, stride, out, in);
        },

        else => {
            l = math.shr(usize, l, 2);

            mr_dit_dr_P(C, w, in, out, s + 2, log2_N);
            mr_dit_dr_P(C, w, in + stride, out + l, s + 2, log2_N);
            mr_dit_dr_P(C, w, in + stride * 2, out + l * 2, s + 2, log2_N);
            mr_dit_dr_P(C, w, in + stride * 3, out + l * 3, s + 2, log2_N);

            mr_dit_bf4_0(C, l, l, out, out);
            mr_dit_bf4_1(C, l, out + l / 2);

            var k: usize = 1;
            while (k < l / 2) : (k += 1) {
                mr_dit_bf4(C, l, out + k, get_twiddle(C, math.shl(usize, k, s), log2_N, w), get_twiddle(C, math.shl(usize, k * 2, s), log2_N, w), get_twiddle_mr(C, math.shl(usize, k * 3, s), log2_N, w));
            }
            k += 1;
            while (k < l) : (k += 1) {
                mr_dit_bf4(C, l, out + k, get_twiddle(C, math.shl(usize, k, s), log2_N, w), get_twiddle(C, math.shl(usize, k * 2, s), log2_N, w), get_twiddle_mr(C, math.shl(usize, k * 3, s), log2_N, w));
            }
        },
    }
}
