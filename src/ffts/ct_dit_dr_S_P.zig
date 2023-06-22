const std = @import("std");
const math = std.math;
const print = std.debug.print;
const Complex = std.math.Complex;

const add = @import("complex_math").add;
const mul = @import("complex_math").mul;
const sub = @import("complex_math").sub;

const negI = @import("complex_math").negI;
const conjI = @import("complex_math").conjI;
const conjNeg = @import("complex_math").conjNeg;

const ct_dit_bf2 = @import("butterflies").ct_dit_bf2;
const ct_dit_bf2_0 = @import("butterflies").ct_dit_bf2_0;
const ct_dit_bf2_pi2 = @import("butterflies").ct_dit_bf2_pi2;
const ct_dit_bf2_pi4 = @import("butterflies").ct_dit_bf2_pi4;
const ct_dit_bf2_3pi4 = @import("butterflies").ct_dit_bf2_3pi4;

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

        2 => {
            ct_dit_bf2_0(C, 1, stride * 2, out, in);
            ct_dit_bf2_0(C, 1, stride * 2, out + 2, in + stride);
            ct_dit_bf2_0(C, 2, 2, out, out);
            ct_dit_bf2_pi2(C, 2, out + 1);
        },

        else => {
            ct_fft_dr(C, w, in, out, s + 1, log2_N);
            ct_fft_dr(C, w, in + stride, out + l, s + 1, log2_N);

            ct_dit_bf2_0(C, l, l, out, out);
            ct_dit_bf2_pi2(C, l, out + l / 2);
            ct_dit_bf2_pi4(C, l, out + l / 4);
            ct_dit_bf2_3pi4(C, l, out + 3 * l / 4);

            var k: usize = 1;
            while (k < l / 4) : (k += 1) {
                var t = get_twiddle(C, math.shl(usize, k, s), log2_N, w);

                ct_dit_bf2(C, l, out + k, t);
                ct_dit_bf2(C, l, out + k + l / 2, negI(t));
                ct_dit_bf2(C, l, out + l / 2 - k, conjI(t));
                ct_dit_bf2(C, l, out + l - k, conjNeg(t));
            }
        },
    }
}
