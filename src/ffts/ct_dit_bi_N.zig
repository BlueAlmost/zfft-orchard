const std = @import("std");
const math = std.math;
const print = std.debug.print;
const Complex = std.math.Complex;

const add = @import("complex_math").add;
const mul = @import("complex_math").mul;
const sub = @import("complex_math").sub;

const bit_reverse = @import("bit_reverse").bit_reverse;

const ct_dit_bf2_0 = @import("butterflies").ct_dit_bf2_0;
const ct_dit_bf2 = @import("butterflies").ct_dit_bf2;

const get_twiddle = @import("Twiddles").Std.get;

pub fn fft(comptime C: type, N: usize, w: [*]C, inout: [*]C) void {
    const log2_N: usize = math.log2(N);
    ct_fft_bi(C, w, inout, log2_N);
}

pub fn ct_fft_bi(comptime C: type, w: [*]C, inout: [*]C, log2_N: usize) void {
    const N: usize = math.shl(usize, 1, log2_N);

    var i: usize = 0;
    var j: usize = 0;
    while (i < N) : (i += 1) {
        j = bit_reverse(i, log2_N);

        if (i < j) {
            var tmp: C = inout[i];
            inout[i] = inout[j];
            inout[j] = tmp;
        }
    }

    // stages 0 to log2_N-1
    j = 0;
    while (j < log2_N) : (j += 1) {
        var s: usize = log2_N - j - 1;
        var l: usize = math.shl(usize, 1, j);
        i = 0;
        while (i < (math.shl(usize, 1, s))) : (i += 1) {
            var t: [*]C = inout + math.shl(usize, i, j + 1);

            var k: usize = 0;
            while (k < l) : (k += 1) {
                ct_dit_bf2(C, l, t + k, get_twiddle(C, math.shl(usize, k, s), log2_N, w));
            }
        }
    }
}
