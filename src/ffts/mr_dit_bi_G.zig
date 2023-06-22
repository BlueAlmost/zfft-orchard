const std = @import("std");
const math = std.math;
const print = std.debug.print;
const Complex = std.math.Complex;

const add = @import("complex_math").add;
const mul = @import("complex_math").mul;
const sub = @import("complex_math").sub;

const bit_reverse_swap_bits = @import("bit_reverse").bit_reverse_swap_bits;

const cp_dit_bf = @import("butterflies").cp_dit_bf;
const cp_dit_bf_0 = @import("butterflies").cp_dit_bf_0;
const cp_dit_bf_pi4 = @import("butterflies").cp_dit_bf_pi4;

const mr_dit_bf4 = @import("butterflies").mr_dit_bf4;
const mr_dit_bf4_0 = @import("butterflies").mr_dit_bf4_0;

const ct_dit_bf2_0 = @import("butterflies").ct_dit_bf2_0;
const ct_dit_bf4_0 = @import("butterflies").ct_dit_bf4_0;

const get_twiddle = @import("Twiddles").Std.get;

pub fn fft(comptime C: type, N: usize, w: [*]C, out: [*]C, in: [*]C) void {
    mr_dit_bi_G(C, w, N, in, out);
}

pub fn mr_dit_bi_G(comptime C: type, w: [*]C, N: usize, in: [*]C, out: [*]C) void {
    const log2_N: usize = math.log2(N);

    // stage 0
    if (log2_N & 1 == 1) {

        // This is BIT_REVERSE42_LOOP
        var i: usize = 0;
        while (i < N) : (i += 4) {
            var r = bit_reverse_swap_bits(i, log2_N);

            ct_dit_bf2_0(C, 1, N / 2, out + i, in + r);
            ct_dit_bf2_0(C, 1, N / 2, out + i + 2, in + r + N / 8);
        }
    } else {
        // This is BIT_REVERSE42_LOOP
        var i: usize = 0;
        while (i < N) : (i += 4) {
            var r = bit_reverse_swap_bits(i, log2_N);

            mr_dit_bf4_0(C, 1, N / 4, out + i, in + r);
        }
    }

    // higher stages
    var j: usize = 2 - (log2_N & 1);
    while (j < log2_N) : (j += 2) {
        var s: usize = log2_N - (j + 2);
        var l: usize = math.shl(usize, 1, j);

        var k: usize = 0;
        while (k < l) : (k += 1) {
            var t1: C = get_twiddle(C, math.shl(usize, k, s), log2_N, w);
            var t2: C = get_twiddle(C, math.shl(usize, k * 2, s), log2_N, w);
            var t3: C = get_twiddle(C, math.shl(usize, k * 3, s), log2_N, w);

            var t: [*]C = out;

            var i: usize = 0;
            while (i < math.shl(usize, 1, s)) : (i += 1) {
                mr_dit_bf4(C, l, t + k, t1, t2, t3);
                t += math.shl(usize, 1, j + 2);
            }
        }
    }
}
