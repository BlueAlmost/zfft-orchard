const std = @import("std");
const math = std.math;
const print = std.debug.print;
const Complex = std.math.Complex;

const neg = @import("complex_math").neg;
const conjI = @import("complex_math").conjI;

const ct_dit_bf2_0 = @import("butterflies").ct_dit_bf2_0;
const ct_dit_bf2 = @import("butterflies").ct_dit_bf2;

const sr_dit_bf4_0 = @import("butterflies").sr_dit_bf4_0;
const sr_dit_bf4_pi4 = @import("butterflies").sr_dit_bf4_pi4;
const sr_dit_bf4 = @import("butterflies").sr_dit_bf4;

const get_twiddle = @import("Twiddles").Std.get;

pub fn fft(comptime C: type, N: usize, w1: [*]C, w3: [*]C, out: [*]C, in: [*]C, sr_input_lut: [*]usize, sr_sched_off: [*]usize, sr_sched_cnt: [*]usize) void {
    const log2_N: usize = math.log2(N);
    sr_dit_bi_G_L_S_P(C, w1, w3, out, in, N, log2_N, sr_input_lut, sr_sched_off, sr_sched_cnt);
}

pub fn sr_dit_bi_G_L_S_P(comptime C: type, w1: [*]C, w3: [*]C, out: [*]C, in: [*]C, N: usize, log2_N: usize, sr_input_lut: [*]usize, sr_sched_off: [*]usize, sr_sched_cnt: [*]usize) void {

    // stage 0
    var j: usize = 0;
    var is: usize = 0;
    while (is < N) : (is += 2) {
        var i_0: usize = sr_input_lut[is / 2];

        if (sr_sched_off[j] * 2 > is) {
            out[is] = in[i_0];
            out[is + 1] = in[i_0 + N / 2];
        } else {
            ct_dit_bf2_0(C, 1, N / 2, out + is, in + i_0);
            j += 1;
        }
    }

    // stage 1
    if (log2_N > 1) {
        var c: usize = sr_sched_cnt[1];
        var i: usize = 0;
        while (i < c) : (i += 1) {
            var o: usize = math.shl(usize, sr_sched_off[i], 2);
            sr_dit_bf4_0(C, 1, out + o);
        }
    }

    // stage 2
    if (log2_N > 2) {
        var c: usize = sr_sched_cnt[2];
        var i: usize = 0;
        while (i < c) : (i += 1) {
            var o: usize = math.shl(usize, sr_sched_off[i], 3);
            sr_dit_bf4_0(C, 2, out + o);
            sr_dit_bf4_pi4(C, 2, out + o + 1);
        }
    }

    // stage >= 3
    if (log2_N > 3) {
        var k: usize = 3;
        while (k < log2_N) : (k += 1) {
            var t: usize = log2_N - k - 1;
            var n2: usize = math.shl(usize, 1, k -% 1);
            var n4: usize = math.shl(usize, 1, k -% 2);

            var c: usize = sr_sched_cnt[k];
            var i: usize = 0;
            while (i < c) : (i += 1) {
                var o: usize = math.shl(usize, sr_sched_off[i], k + 1);
                sr_dit_bf4_0(C, n2, out + o);
                sr_dit_bf4_pi4(C, n2, out + o + n4);
            }

            var j0: usize = 1;
            while (j0 < n4) : (j0 += 1) {
                var tw1: C = get_twiddle(C, math.shl(usize, j0, t), log2_N, w1);
                var tw3: C = get_twiddle(C, math.shl(usize, j0, t), log2_N, w3);

                i = 0;
                while (i < c) : (i += 1) {
                    var o: usize = math.shl(usize, sr_sched_off[i], k + 1);
                    sr_dit_bf4(C, n2, out + o + j0, tw1, tw3);
                    sr_dit_bf4(C, n2, out + o + n2 - j0, conjI(tw1), neg(conjI(tw3)));
                }
            }
        }
    }
}
