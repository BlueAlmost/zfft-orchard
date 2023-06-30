const std = @import("std");
const math = std.math;
const Complex = std.mat.Complex;
const print = std.debug.print;

const ValueType = @import("type_helpers").ValueType;

// No Twiddles -------------------------------------------------------
pub const None = struct {
    pub fn init(comptime C: type, l: usize, N: usize, twiddles: [*]C) void {
        // _ = C;
        _ = l;
        _ = N;
        _ = twiddles;
    }

    pub fn get(comptime C: type, i: usize, log2_N: usize) C {
        const V = ValueType(C);
        const N = math.shl(usize, 1, log2_N);
        const theta: V = -2 * math.pi * @as(V, @floatFromInt(i)) / @as(V, @floatFromInt(N));
        return C.init(@cos(theta), @sin(theta));
    }

    pub fn get_sr(comptime C: type, i: usize, log2_N: usize) C {
        const V = ValueType(C);
        const N = math.shl(usize, 1, log2_N);
        const theta: V = -2 * math.pi * @as(V, @floatFromInt(3 * i)) / @as(V, @floatFromInt(N));
        return C.init(@cos(theta), @sin(theta));
    }

    pub fn get_mr(comptime C: type, i: usize, log2_N: usize) C {
        return get(C, i, log2_N);
    }
};

// Short Twiddles -------------------------------------------------------
pub const Short = struct {
    pub fn init(comptime C: type, _: usize, N: usize, twiddles: [*]C) void {
        const V = ValueType(C);
        const l: usize = N / 8 + 1;
        // var theta: V = undefined;
        var i: usize = 0;
        while (i < l) : (i += 1) {
            var theta: V = -2.0 * math.pi * @as(V, @floatFromInt(i)) / @as(V, @floatFromInt(N));
            twiddles[i].re = @cos(theta);
            twiddles[i].im = @sin(theta);
        }
    }

    pub fn get(comptime C: type, k: usize, log2_N: usize, twiddles: [*]C) C {

        // Method is based on: "Scheme for reducing size of coefficient memory
        // in FFT processor", M. Hasan and T. Arslan.  Electronic Letters,
        // Feb 14, 2002, Vol. 38, No. 4.

        // Bit-tricks used to avoid condition if statements, etc are drawn from
        // Alexandre Becoulet's "fft garden" released to the public domain 2019
        // under CCO Public Domain.  See: https://github.com/diaxen/fft-garden.

        // Retrieve the k^th entry of a standard twiddle table:  w[k] = exp(-j*2*pi*k/N)
        // having N/2 entries, from a "short twiddle table", twiddles[.] containing
        // only (N/8)+1 entries.

        const T = ValueType(C);

        const U = switch (T) {
            f16 => u16,
            f32 => u32,
            f64 => u64,
            else => {
                @compileError("unexpected type");
            },
        };

        // union is used to do bit-tricks on indexing, swapping and negating
        // without conditional statement breaking pipelining
        const FltUint = extern union {
            f: T,
            u: U,
        };
        var vr: FltUint = undefined;
        var vi: FltUint = undefined;

        // determine i, the "block index", i.e. which of 4 "blocks" k resides in
        const m: U = math.shl(U, 1, log2_N - 3);
        const i: U = @as(U, @truncate(k)) / m;

        // swp is set for block indices 1 and 2.
        // these blocks swap real <--> imaginary components
        // also effects negation in concert with block index being odd/even
        const swp: U = (i ^ (i >> 1)) & 1;

        // i == 0  -->  (  r,  i ),    swp = 0
        // i == 1  -->  ( -i, -r ),    swp = 1
        // i == 2  -->  (  i, -r ),    swp = 1
        // i == 3  -->  ( -r,  i ),    swp = 0

        // q is the index into the "short table" z(of length N/8+1),
        // depends on whether block index is odd/even
        var q: usize = k & (m -% 1);
        if (i & 1 == 1) {
            q = m - q;
        }

        // obtain pointer into proper location of short table z and
        // perform swapping and negation as needed.
        var twiddles_p: [*]U = @as([*]U, @ptrCast(&twiddles[q]));
        vi.u = twiddles_p[swp ^ 1] ^ (math.shl(U, swp, @bitSizeOf(U) - 1));
        vr.u = twiddles_p[swp] ^ (math.shl(U, (i & 1), @bitSizeOf(U) - 1));

        return C.init(vr.f, vi.f);
    }

    pub fn get_sr(comptime C: type, i: usize, log2_N: usize, twiddles: [*]C) C {
        var tw = get(C, 3 * i, log2_N, twiddles);

        // angle can be greater than pi
        if (math.shr(usize, 3 * i, log2_N - 1) > 0) {
            tw.re = -tw.re;
            tw.im = -tw.im;
        }
        return tw;
    }

    pub fn get_mr(comptime C: type, i: usize, log2_N: usize) C {
        var tw = get(C, i, log2_N);

        if (math.shr(usize, i, log2_N - 1) > 0) {
            tw.re = -tw.re;
            tw.im = -tw.im;
        }

        return tw;
    }
};

// Standard Twiddles ------------------------------------------------------------
pub const Std = struct {
    pub fn init(comptime C: type, l: usize, N: usize, twiddles: [*]C) void {
        const V = ValueType(C);
        // var theta: V = undefined;
        var i: usize = 0;
        while (i < l) : (i += 1) {
            var theta: V = -2.0 * std.math.pi * @as(V, @floatFromInt(i)) / @as(V, @floatFromInt(N));
            twiddles[i].re = @cos(theta);
            twiddles[i].im = @sin(theta);
        }
    }

    pub fn get(comptime C: type, i: usize, log2_N: usize, twiddles: [*]C) C {
        _ = log2_N;
        return twiddles[i];
    }

    pub fn get_sr(comptime C: type, i: usize, log2_N: usize, twiddles_sr: [*]C) C {
        _ = log2_N;
        return twiddles_sr[i];
    }

    pub fn get_mr(comptime C: type, i: usize, log2_N: usize, twiddles: [*]C) C {
        return get(C, i, log2_N, twiddles);
    }

    pub fn sr_init(comptime C: type, l: usize, N: usize, twiddles: [*]C, twiddles_sr: [*]C) void {
        const V = ValueType(C);
        var theta: V = undefined;
        var i: usize = 0;
        while (i < l) : (i += 1) {
            theta = -2.0 * std.math.pi * @as(V, @floatFromInt(i)) / @as(V, @floatFromInt(N));
            twiddles[i].re = @cos(theta);
            twiddles[i].im = @sin(theta);

            twiddles_sr[i].re = @cos(3.0 * theta);
            twiddles_sr[i].im = @sin(3.0 * theta);
        }
    }
};
