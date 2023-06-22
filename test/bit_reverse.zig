const std = @import("std");
const print = std.debug.print;

const bit_reverse = @import("bit_reverse").bit_reverse;
const bit_reverse_swap_bits = @import("bit_reverse").bit_reverse_swap_bits;

pub fn main() !void {
    print("\n\ttesting bit reverse utils:\n", .{});

    print("\t\t bit_reverse \t\t...", .{});

    inline for (.{ u3, u16, u32, usize }) |T| {
        const log2_N: usize = 3;

        try std.testing.expect(bit_reverse(@as(T, 0), log2_N) == 0);
        try std.testing.expect(bit_reverse(@as(T, 1), log2_N) == 4);
        try std.testing.expect(bit_reverse(@as(T, 2), log2_N) == 2);
        try std.testing.expect(bit_reverse(@as(T, 3), log2_N) == 6);
        try std.testing.expect(bit_reverse(@as(T, 4), log2_N) == 1);
        try std.testing.expect(bit_reverse(@as(T, 5), log2_N) == 5);
        try std.testing.expect(bit_reverse(@as(T, 6), log2_N) == 3);
        try std.testing.expect(bit_reverse(@as(T, 7), log2_N) == 7);
    }
    print("\tpassed.\n", .{});

    print("\t\t bit_reverse_swap_bits \t...", .{});

    inline for (.{ u16, u32, usize }) |T| {
        // inline for (.{ usize }) |T| {

        const log2_N: usize = 5;

        try std.testing.expect(bit_reverse_swap_bits(@as(T, 0), log2_N) == 0);
        try std.testing.expect(bit_reverse_swap_bits(@as(T, 4), log2_N) == 8);
        try std.testing.expect(bit_reverse_swap_bits(@as(T, 8), log2_N) == 1);
        try std.testing.expect(bit_reverse_swap_bits(@as(T, 12), log2_N) == 9);

        try std.testing.expect(bit_reverse_swap_bits(@as(T, 16), log2_N) == 2);
        try std.testing.expect(bit_reverse_swap_bits(@as(T, 20), log2_N) == 10);
        try std.testing.expect(bit_reverse_swap_bits(@as(T, 24), log2_N) == 3);
        try std.testing.expect(bit_reverse_swap_bits(@as(T, 28), log2_N) == 11);
    }
    print("\tpassed.\n", .{});
}
