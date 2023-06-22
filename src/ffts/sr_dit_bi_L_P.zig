const std = @import("std");
const math = std.math;
const print = std.debug.print;
const Complex = std.math.Complex;

const ct_dit_bf2_0 = @import("butterflies").ct_dit_bf2_0;
const ct_dit_bf2 = @import("butterflies").ct_dit_bf2;

const sr_dit_bf4_0 = @import("butterflies").sr_dit_bf4_0;
const sr_dit_bf4_pi4 = @import("butterflies").sr_dit_bf4_pi4;
const sr_dit_bf4 = @import("butterflies").sr_dit_bf4;

const get_twiddle = @import("Twiddles").Std.get;

pub fn fft(comptime C: type, N: usize, w1: [*]C, w3: [*]C, out: [*]C, in: [*]C, sr_input_lut: [*]usize, sr_sched_off: [*]usize, sr_sched_cnt: [*]usize) void {
    const log2_N: usize = math.log2(N);

    sr_dit_bi_L_P(C, w1, w3, out, in, N, log2_N, sr_input_lut, sr_sched_off, sr_sched_cnt);
}

pub fn sr_dit_bi_L_P(comptime C: type, w1: [*]C, w3: [*]C, out: [*]C, in: [*]C, N: usize, log2_N: usize, sr_input_lut: [*]usize, sr_sched_off: [*]usize, sr_sched_cnt: [*]usize) void {

    // stage 0
    var j: usize = 0;
    var i: usize = 0;
    while (i < N) : (i += 2) {
        var i_0: usize = sr_input_lut[i / 2];

        if (sr_sched_off[j] * 2 > i) {
            out[i] = in[i_0];
            out[i + 1] = in[i_0 + N / 2];
        } else {
            ct_dit_bf2_0(C, 1, N / 2, out + i, in + i_0);
            j += 1;
        }
    }

    // stage 1
    if (log2_N > 1) {
        var c: usize = sr_sched_cnt[1];
        i = 0;
        while (i < c) : (i += 1) {
            var o: usize = math.shl(usize, sr_sched_off[i], 2);
            sr_dit_bf4_0(C, 1, out + o);
        }
    }

    // stage 2
    if (log2_N > 2) {
        var c: usize = sr_sched_cnt[2];
        i = 0;
        while (i < c) : (i += 1) {
            var o: usize = math.shl(usize, sr_sched_off[i], 3);
            sr_dit_bf4_0(C, 2, out + o);
            sr_dit_bf4_pi4(C, 2, out + o + 1);
        }
    }

    // stage >= 3
    if (log2_N > 3) {
        var s: usize = 3;
        while (s < log2_N) : (s += 1) {
            var c: usize = sr_sched_cnt[s];
            i = 0;
            while (i < c) : (i += 1) {
                var o: [*]C = out + math.shl(usize, sr_sched_off[i], s + 1);
                var t: usize = log2_N - s - 1;
                var os: usize = math.shl(usize, 1, s - 1);

                sr_dit_bf4_0(C, os, o);
                sr_dit_bf4_pi4(C, os, o + os / 2);

                var k: usize = 1;
                while (k < os / 2) : (k += 1) {
                    sr_dit_bf4(C, os, o + k, get_twiddle(C, math.shl(usize, k, t), log2_N, w1), get_twiddle(C, math.shl(usize, k, t), log2_N, w3));
                }

                k += 1;
                while (k < os) : (k += 1) {
                    sr_dit_bf4(C, os, o + k, get_twiddle(C, math.shl(usize, k, t), log2_N, w1), get_twiddle(C, math.shl(usize, k, t), log2_N, w3));
                }
            }
        }
    }
}
