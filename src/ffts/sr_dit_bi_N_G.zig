const std = @import("std");
const math = std.math;
const print = std.debug.print;
const Complex = std.math.Complex;

const bit_reverse = @import("bit_reverse").bit_reverse;

const ct_dit_bf2_0 = @import("butterflies").ct_dit_bf2_0;
const ct_dit_bf2 = @import("butterflies").ct_dit_bf2;

const sr_dit_bf4 = @import("butterflies").sr_dit_bf4;

const get_twiddle = @import("Twiddles").Std.get;

pub fn fft(comptime C: type, N: usize, w: [*]C, w3: [*]C, inout: [*]C) void {
    const log2_N: usize = math.log2(N);
    sr_dit_bi_N_G(C, w, w3, inout, N, log2_N);
}

pub fn sr_dit_bi_N_G(comptime C: type, w: [*]C, w3: [*]C, inout: [*]C, N: usize, log2_N: usize) void {
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

    // length 2 transforms
    var is: usize = 0;
    var id: usize = 4;
    var i_0: usize = undefined;

    while (is < N) {
        i_0 = is;
        while (i_0 < N) : (i_0 += id) {
            ct_dit_bf2_0(C, 1, 1, inout + i_0, inout + i_0);
        }
        is = 2 * id - 2;
        id = 4 * id;
    }

    if (log2_N < 2) {
        return;
    }

    // L shaped butterflies

    var k: usize = 2;
    while (k <= log2_N) : (k += 1) {
        var n2: usize = math.shl(usize, 1, k);
        var n4: usize = math.shr(usize, n2, 2);

        j = 0;
        while (j < n4) : (j += 1) {
            var t: usize = math.shl(usize, j, log2_N - k);
            var tw1: C = get_twiddle(C, t, log2_N, w);
            var tw3: C = get_twiddle(C, t, log2_N, w3);

            is = j;
            id = math.shl(usize, 2, k);
            while (is < N) {
                i_0 = is;
                while (i_0 < N) : (i_0 += id) {
                    sr_dit_bf4(C, n4, inout + i_0, tw1, tw3);
                }
                is = 2 * id - n2 + j;
                id = 4 * id;
            }
        }
    }
}
