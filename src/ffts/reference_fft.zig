const std = @import("std");
const math = std.math;
const print = std.debug.print;
const Complex = std.math.Complex;

const add = @import("complex_math").add;
const mul = @import("complex_math").mul;
const sub = @import("complex_math").sub;

const ValueType = @import("type_helpers").ValueType;

// this simple fft may be used as reference implementation
pub fn fft(comptime C: type, size: usize, out: [*]C, in: [*]C, stride: usize) void {
    const V = ValueType(C);

    const half: usize = size >> 1;

    if (half == 0) {
        out[0] = in[0];
    } else {
        fft(C, half, out, in, stride << 1);
        fft(C, half, out + half, in + stride, stride << 1);

        var i: usize = 0;
        while (i < half) : (i += 1) {
            var a: C = out[i];
            var b: C = out[i + half];

            var angle: V = 2 * math.pi * @intToFloat(V, i) / @intToFloat(V, size);
            var tw: C = undefined;

            tw.re = @cos(angle);
            tw.im = -@sin(angle);

            var c: C = mul(b, tw);
            out[i] = add(a, c);
            out[i + half] = sub(a, c);
        }
    }
}
