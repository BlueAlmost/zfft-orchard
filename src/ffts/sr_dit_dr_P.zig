const std = @import("std");
const math = std.math;
const print = std.debug.print;
const Complex = std.math.Complex;

const mr_dit_bf4 = @import("butterflies").mr_dit_bf4;
const mr_dit_bf4_0 = @import("butterflies").mr_dit_bf4_0;

const sr_dit_bf4 = @import("butterflies").sr_dit_bf4;
const sr_dit_bf4_0 = @import("butterflies").sr_dit_bf4_0;
const sr_dit_bf4_pi4 = @import("butterflies").sr_dit_bf4_pi4;

const ct_dit_bf2_0 = @import("butterflies").ct_dit_bf2_0;

const get_twiddle = @import("Twiddles").Std.get;
const get_twiddle_sr = @import("Twiddles").Std.get_sr;

pub fn fft(comptime C: type, N: usize, w: [*]C, w_sr: [*]C, out: [*]C, in: [*]C) void {
    const log2_N: usize = math.log2(N);
    sr_dit_dr_P(C, w, w_sr, log2_N, in, out, log2_N, 0);
}

pub fn sr_dit_dr_P(comptime C: type, w: [*]C, w_sr: [*]C, log2_N: usize, in: [*]C, out: [*]C, l: usize, i: usize) void {
    var is: usize = math.shl(usize, 1, log2_N -% l);

    var os: usize = math.shl(usize, 1, l -% 2);

    var t: usize = log2_N - l;

    switch (l) {

        // size 2 base case
        1 => {
            ct_dit_bf2_0(C, 1, is, out, in + i);
        },

        // size 4 base case
        2 => {
            ct_dit_bf2_0(C, 1, is * 2, out, in + i);

            out[2] = in[i + is];
            out[3] = in[i + 3 * is];
            sr_dit_bf4_0(C, 1, out);
        },

        else => {
            sr_dit_dr_P(C, w, w_sr, log2_N, in, out, l - 1, i);
            sr_dit_dr_P(C, w, w_sr, log2_N, in, out + os * 2, l - 2, i + is);
            sr_dit_dr_P(C, w, w_sr, log2_N, in, out + os * 3, l - 2, i + is * 3);

            sr_dit_bf4_0(C, os, out);
            sr_dit_bf4_pi4(C, os, out + os / 2);

            var k: usize = 1;
            while (k < os / 2) : (k += 1) {
                sr_dit_bf4(C, os, out + k, get_twiddle(C, math.shl(usize, k, t), log2_N, w), get_twiddle_sr(C, math.shl(usize, k, t), log2_N, w_sr));
            }
            k += 1;
            while (k < os) : (k += 1) {
                sr_dit_bf4(C, os, out + k, get_twiddle(C, math.shl(usize, k, t), log2_N, w), get_twiddle_sr(C, math.shl(usize, k, t), log2_N, w_sr));
            }
        },
    }
}
