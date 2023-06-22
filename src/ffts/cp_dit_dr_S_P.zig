const std = @import("std");
const math = std.math;
const print = std.debug.print;
const Complex = std.math.Complex;

const add = @import("complex_math").add;
const mul = @import("complex_math").mul;
const sub = @import("complex_math").sub;
const negIConj = @import("complex_math").negIConj;
const conj = @import("complex_math").conj;

const cp_dit_bf = @import("butterflies").cp_dit_bf;
const cp_dit_bf_0 = @import("butterflies").cp_dit_bf_0;
const cp_dit_bf_pi4 = @import("butterflies").cp_dit_bf_pi4;

const get_twiddle = @import("Twiddles").Std.get;

pub fn fft(comptime C: type, N: usize, w: [*]C, out: [*]C, in: [*]C) void {
    const log2_N: usize = math.log2(N);
    cp_dit_dr(C, w, log2_N, in, out, log2_N, 0);
}

pub fn cp_dit_dr(comptime C: type, w: [*]C, log2_N: usize, in: [*]C, out: [*]C, l: usize, i: usize) void {
    var is: usize = math.shl(usize, 1, log2_N -% l);
    var os: usize = math.shl(usize, 1, l -% 2);

    var mask: usize = math.shl(usize, 1, log2_N) - 1;
    var i_0: usize = i & mask;
    var t: usize = log2_N - l;

    switch (l) {
        0 => {
            // do nothing here
        },

        // size 2 base case
        1 => {
            var i_1: usize = i_0 ^ is;
            var a: C = in[i_0];
            var b: C = in[i_1];
            out[0] = add(a, b);
            out[1] = sub(a, b);
        },

        // size 4 base case
        2 => {
            var i_1: usize = i_0 ^ math.shl(usize, 1, (log2_N - 1));
            var a: C = in[i_0];
            var b: C = in[i_1];
            out[0] = add(a, b);
            out[1] = sub(a, b);

            out[2] = in[(i +% is) & mask];
            out[3] = in[(i -% is) & mask];
            cp_dit_bf_0(C, 1, out);
        },

        else => {
            cp_dit_dr(C, w, log2_N, in, out, l -% 1, i);
            cp_dit_dr(C, w, log2_N, in, out + 2 * os, l -% 2, i +% is);
            cp_dit_dr(C, w, log2_N, in, out + 3 * os, l -% 2, i -% is);

            var m: usize = os / 2;

            if (os > 2) {
                var k: usize = 1;
                while (k < m) : (k += 1) {
                    var tw: C = get_twiddle(C, math.shl(usize, k, t), log2_N, w);
                    cp_dit_bf(C, os, out + k, tw);
                    cp_dit_bf(C, os, out + os - k, negIConj(tw));
                }
            }
            cp_dit_bf_pi4(C, os, out + m);
            cp_dit_bf_0(C, os, out);
        },
    }
}
