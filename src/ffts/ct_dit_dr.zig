const std = @import("std");
const math = std.math;
const print = std.debug.print;
const Complex = std.math.Complex;

const add = @import("complex_math").add;
const mul = @import("complex_math").mul;
const sub = @import("complex_math").sub;

const ct_dit_bf2_0 = @import("butterflies").ct_dit_bf2_0;
const ct_dit_bf2 = @import("butterflies").ct_dit_bf2;

const get_twiddle = @import("Twiddles").Std.get;

pub fn fft(comptime C: type, N: usize, w: [*]C, out: [*]C, in: [*]C) void {
    const log2_N: usize = math.log2(N);
    ct_fft_dr(C, w, in, out, 0, log2_N);
}

pub fn ct_fft_dr(comptime C: type, w: [*]C, in: [*]C, out: [*]C, s: usize, log2_N: usize) void {
    const l: usize = math.shl(usize, 1, log2_N - s - 1);
    var stride: usize = math.shl(usize, 1, s);

    switch (l) {
        1 => {
            ct_dit_bf2_0(C, 1, stride, out, in);
        },

        else => {
            ct_fft_dr(C, w, in, out, s + 1, log2_N);
            ct_fft_dr(C, w, in + stride, out + l, s + 1, log2_N);

            var k: usize = 0;
            while (k < l) : (k += 1) {
                ct_dit_bf2(C, l, out + k, get_twiddle(C, math.shl(usize, k, s), log2_N, w));
            }
        },
    }
}
