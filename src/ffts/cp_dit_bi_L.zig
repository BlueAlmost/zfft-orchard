const std = @import("std");
const math = std.math;
const print = std.debug.print;
const Complex = std.math.Complex;

const add = @import("complex_math").add;
const sub = @import("complex_math").sub;

const cp_dit_bf = @import("butterflies").cp_dit_bf;
const cp_dit_bf_0 = @import("butterflies").cp_dit_bf_0;
const cp_dit_bf_pi4 = @import("butterflies").cp_dit_bf_pi4;

const get_twiddle = @import("Twiddles").Std.get;
const twiddle_init = @import("Twiddles").Std.init;

pub fn fft(comptime C: type, N: usize, w: [*]C, out: [*]C, in: [*]C, cp_input_lut: [*]usize, sr_sched_off: [*]usize, sr_sched_cnt: [*]usize) void {
    cp_dit_bi_L(C, w, N, in, out, cp_input_lut, sr_sched_off, sr_sched_cnt);
}

pub fn cp_dit_bi_L(comptime C: type, w: [*]C, N: usize, in: [*]C, out: [*]C, cp_input_lut: [*]usize, sr_sched_off: [*]usize, sr_sched_cnt: [*]usize) void {
    const log2_N: usize = math.log2(N);

    // stage 0
    var i: usize = 0;
    var j: usize = 0;
    while (i < N) : (i += 2) {
        var i_0: usize = cp_input_lut[i / 2];
        var i_1: usize = i_0 ^ math.shr(usize, N, 1);

        if (sr_sched_off[j] * 2 > i) {
            out[i] = in[i_0];
            out[i + 1] = in[i_1];
        } else {
            var a: C = in[i_0];
            var b: C = in[i_1];
            out[i] = add(a, b);
            out[i + 1] = sub(a, b);
            j += 1;
        }
    }

    // stage >= 1
    if (log2_N > 1) {
        var s: usize = 1;
        while (s < log2_N) : (s += 1) {
            var c: usize = sr_sched_cnt[s];

            i = 0;
            while (i < c) : (i += 1) {
                var o: usize = math.shl(usize, sr_sched_off[i], s + 1);
                var t: usize = log2_N - s - 1;
                var os: usize = math.shl(usize, 1, s - 1);

                var k: usize = 0;
                while (k < os) : (k += 1) {
                    cp_dit_bf(C, os, out + o + k, get_twiddle(C, math.shl(usize, k, t), log2_N, w));
                }
            }
        }
    }
}
