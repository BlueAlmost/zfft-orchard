const std = @import("std");
const math = std.math;
const Complex = std.math.Complex;
const print = std.debug.print;

const ElementType = @import("type_helpers").ElementType;
const ValueType = @import("type_helpers").ValueType;

pub fn gen_data(x: anytype) void {
    const T = @TypeOf(x);
    const E = ElementType(T);
    const V = ValueType(E);

    var rnd = std.rand.DefaultPrng.init(42);
    for (x, 0..) |_, i| {
        x[i].re = rnd.random().float(V) - 0.5;
        x[i].im = rnd.random().float(V) - 0.5;
    }
}

test "\t gen_data\n" {
    var arena = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    inline for (.{ f32, f64 }) |T| {
        const C: type = Complex(T);

        const n: usize = 10;
        var x = try allocator.alloc(C, n);
        gen_data(x);

        try std.testing.expectEqual(x.len, n);
    }
}
