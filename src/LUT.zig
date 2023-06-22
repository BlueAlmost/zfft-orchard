const std = @import("std");
const math = std.math;
const print = std.debug.print;
const Complex = std.math.Complex;

const isSignedInt = std.meta.trait.isSignedInt;
const Allocator = std.mem.Allocator;

const ValueType = @import("type_helpers").ValueType;

// Conjugate Pair Lookup Table ----------------------------------------
pub const CP = struct {
    pub fn input_lut_init(comptime T: type, N: T, input_lut: [*]T) void {
        const log2_N: T = math.log2(N);

        const r = @bitSizeOf(T) - log2_N;

        const val_to_shift: T = math.shl(T, 1, @bitSizeOf(T) - 3);

        var p: T = 0;
        var q: T = 0;

        var h: T = 0;
        var hn: T = 0;

        while (h < N) : (h = hn) {

            // eval binary carry sequency
            hn = h + 2;
            var c: T = @bitSizeOf(T) - 2 - @clz(h ^ hn);

            // input indices
            var i_0: T = math.shr(T, (p -% q), r);

            input_lut[h / 2] = i_0;

            // advance to next input index
            var m2: T = math.shr(T, val_to_shift, c);
            var m1: T = m2 - 1;
            var m: T = p & m2;

            q = (q & m1) | m;
            p = (p & m1) | ((m ^ m2) << 1);
        }
    }
};

// Split Radix Lookup Table ----------------------------------------
pub const SR = struct {
    pub fn input_lut_init(comptime T: type, N: T, input_lut: [*]T) void {
        const log2_N: T = math.log2(N);

        lut_dr(T, log2_N, 0, log2_N, 0, input_lut);
    }

    pub fn lut_dr(comptime T: type, log2_N: T, out: T, l: T, i: T, input_lut: [*]T) void {
        var is: T = math.shl(T, 1, log2_N - l);
        var os: T = math.shl(T, 1, l -% 2);

        switch (l) {
            1 => {
                input_lut[out / 2] = i;
            },

            2 => {
                lut_dr(T, log2_N, out, 1, i, input_lut);
                input_lut[1 + out / 2] = i + is;
            },
            else => {
                lut_dr(T, log2_N, out, l - 1, i, input_lut);
                lut_dr(T, log2_N, out + os * 2, l - 2, i + is, input_lut);
                lut_dr(T, log2_N, out + 3 * os, l - 2, i + 3 * is, input_lut);
            },
        }
    }

    pub fn jacobsthal(n: anytype) @TypeOf(n) {
        comptime var T = @TypeOf(n);
        if (comptime isSignedInt(T)) {
            @compileError("accepts only unsigned integer types");
        }

        // returns the n-th jacobsthal number using closed-for equation
        // J(n) = (2^n - (-1)^n) / 3

        if (n & 1 == 1) {
            return ((math.shl(T, 1, n) + 1) / 3);
        } else {
            return ((math.shl(T, 1, n) - 1) / 3);
        }
    }

    // NOTE:  do the allocations for sr_sched_cnt, and sr_sched_off elsewhere

    pub fn sched_lut_init(comptime T: type, N: T, sched_cnt: [*]T, sched_off: [*]T) void {
        const log2_N: T = math.log2(N);

        var i: T = 0;
        while (i < log2_N) : (i += 1) {
            sched_cnt[i] = jacobsthal(log2_N - i);
        }

        i = 0;
        var j: T = 0;
        while (j < sched_cnt[0]) : (i += 1) {
            if ((@clz(i ^ (i + 1)) & 1) == 1) {
                sched_off[j] = i;
                j += 1;
            }
        }
        sched_off[j] = N;
    }
};
