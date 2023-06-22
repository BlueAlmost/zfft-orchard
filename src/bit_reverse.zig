const std = @import("std");
const math = std.math;
const Complex = std.math.complex.Complex;

const Allocator = std.mem.Allocator;
const print = std.debug.print;

pub inline fn bit_reverse(i: anytype, log2_N: usize) @TypeOf(i) {
    const T = @TypeOf(i);
    return math.shr(T, @bitReverse(i), @bitSizeOf(T) - log2_N);
}

pub inline fn bit_reverse_swap_bits(i: anytype, log2_N: usize) @TypeOf(i) {
    const T = @TypeOf(i);

    var r: T = math.shr(T, @bitReverse(i), @bitSizeOf(T) - log2_N);

    const evens: T = switch (T) {
        u16 => 0x5555,
        u32 => 0x5555_5555,
        u64, usize => 0x5555_5555_5555_5555,
        else => @compileError("unexpected type"),
    };

    const odds: T = switch (T) {
        u16 => 0xaaaa,
        u32 => 0xaaaa_aaaa,
        u64, usize => 0xaaaa_aaaa_aaaa_aaaa,
        else => @compileError("unexpected type"),
    };

    var j: T = math.shl(T, (r & evens), 1) | math.shr(T, (r & odds), 1);

    return j;
}
