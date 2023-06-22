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

const bit_reverse = @import("bit_reverse").bit_reverse;

const ct_dit_bf2 = @import("butterflies").ct_dit_bf2;
const ct_dit_bf2_0 = @import("butterflies").ct_dit_bf2_0;
const ct_dit_bf2_pi4 = @import("butterflies").ct_dit_bf2_pi4;
const ct_dit_bf2_pi2 = @import("butterflies").ct_dit_bf2_pi2;
const ct_dit_bf2_3pi4 = @import("butterflies").ct_dit_bf2_3pi4;

const get_twiddle = @import("Twiddles").Std.get;

pub fn fft(comptime C: type, N: usize, w: [*]C, out: [*]C, in: [*]C) void {
    const log2_N: usize = math.log2(N);
    ct_fft_bi(C, w, in, out, log2_N);
}

pub fn ct_fft_bi(comptime C: type, w: [*]C, in: [*]C, out: [*]C, log2_N: usize) void {
    const N: usize = math.shl(usize, 1, log2_N);

    // stage 0
    var i: usize = 0;
    var j: usize = 0;
    while (i < N) : (i += 2) {
        j = bit_reverse(i, log2_N);
        ct_dit_bf2_0(C, 1, N / 2, out + i, in + j);
    }

    // stage 1
    i = 0;
    while (i < N / 4) : (i += 1) {
        var t: [*]C = out + math.shl(usize, i, 2);
        ct_dit_bf2_0(C, 2, 2, t, t);
        ct_dit_bf2_pi2(C, 2, t + 1);
    }

    // stages 2 to log2_N -1
    j = 2;
    while (j < log2_N) : (j += 1) {
        var s: usize = log2_N - j - 1;
        var l: usize = math.shl(usize, 1, j);

        i = 0;
        while (i < math.shl(usize, 1, s)) : (i += 1) {
            var t: [*]C = out + math.shl(usize, i, j + 1);
            ct_dit_bf2_0(C, l, l, t, t);
            ct_dit_bf2_pi2(C, l, t + l / 2);
            ct_dit_bf2_pi4(C, l, t + l / 4);
            ct_dit_bf2_3pi4(C, l, t + 3 * l / 4);
        }

        var k: usize = 1;
        while (k < l / 4) : (k += 1) {
            var tw: C = get_twiddle(C, math.shl(usize, k, s), log2_N, w);
            var t: [*]C = out;

            i = 0;
            while (i < math.shl(usize, 1, s)) : (i += 1) {
                ct_dit_bf2(C, l, t + k, tw);
                ct_dit_bf2(C, l, t + k + l / 2, negI(tw));
                ct_dit_bf2(C, l, t + l / 2 - k, conjI(tw));
                ct_dit_bf2(C, l, t + l - k, conjNeg(tw));
                t += math.shl(usize, 1, j + 1);
            }
        }
    }
}
