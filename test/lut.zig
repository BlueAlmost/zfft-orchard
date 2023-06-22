const std = @import("std");
const math = std.math;
const print = std.debug.print;
const Complex = std.math.Complex;

const ValueType = @import("../utils/helpers.zig").ValueType;

const LUT = @import("LUT");

pub fn main() !void {
    print("\n\ttesting LUT:\n", .{});

    try test_cp_input_lut();
    try test_sr_input_lut();
    try test_jacobsthal();
    try test_sr_sched_init();
}

pub fn test_cp_input_lut() !void {
    print("\t\t LUT cp input\t\t...", .{});

    inline for (.{ u32, u64, usize }) |T| {
        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer arena.deinit();

        const allocator = arena.allocator();
        var N: T = 32;
        var cp_input_lut = try allocator.alloc(T, N / 2);

        LUT.CP.input_lut_init(T, N, cp_input_lut.ptr);

        try std.testing.expect(@as(T, 0) == cp_input_lut[0]);
        try std.testing.expect(@as(T, 8) == cp_input_lut[1]);
        try std.testing.expect(@as(T, 4) == cp_input_lut[2]);
        try std.testing.expect(@as(T, 28) == cp_input_lut[3]);

        try std.testing.expect(@as(T, 2) == cp_input_lut[4]);
        try std.testing.expect(@as(T, 10) == cp_input_lut[5]);
        try std.testing.expect(@as(T, 30) == cp_input_lut[6]);
        try std.testing.expect(@as(T, 6) == cp_input_lut[7]);

        try std.testing.expect(@as(T, 1) == cp_input_lut[8]);
        try std.testing.expect(@as(T, 9) == cp_input_lut[9]);
        try std.testing.expect(@as(T, 5) == cp_input_lut[10]);
        try std.testing.expect(@as(T, 29) == cp_input_lut[11]);

        try std.testing.expect(@as(T, 31) == cp_input_lut[12]);
        try std.testing.expect(@as(T, 7) == cp_input_lut[13]);
        try std.testing.expect(@as(T, 3) == cp_input_lut[14]);
        try std.testing.expect(@as(T, 27) == cp_input_lut[15]);
    }
    print("\tpassed.\n", .{});
}

pub fn test_sr_input_lut() !void {
    print("\t\t LUT sr input\t\t...", .{});

    inline for (.{ u32, u64, usize }) |T| {
        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer arena.deinit();

        const allocator = arena.allocator();
        var N: T = 32;
        var sr_input_lut = try allocator.alloc(T, N / 2);

        LUT.SR.input_lut_init(T, N, sr_input_lut.ptr);

        try std.testing.expect(@as(T, 0) == sr_input_lut[0]);
        try std.testing.expect(@as(T, 8) == sr_input_lut[1]);
        try std.testing.expect(@as(T, 4) == sr_input_lut[2]);
        try std.testing.expect(@as(T, 12) == sr_input_lut[3]);

        try std.testing.expect(@as(T, 2) == sr_input_lut[4]);
        try std.testing.expect(@as(T, 10) == sr_input_lut[5]);
        try std.testing.expect(@as(T, 6) == sr_input_lut[6]);
        try std.testing.expect(@as(T, 14) == sr_input_lut[7]);

        try std.testing.expect(@as(T, 1) == sr_input_lut[8]);
        try std.testing.expect(@as(T, 9) == sr_input_lut[9]);
        try std.testing.expect(@as(T, 5) == sr_input_lut[10]);
        try std.testing.expect(@as(T, 13) == sr_input_lut[11]);

        try std.testing.expect(@as(T, 3) == sr_input_lut[12]);
        try std.testing.expect(@as(T, 11) == sr_input_lut[13]);
        try std.testing.expect(@as(T, 7) == sr_input_lut[14]);
        try std.testing.expect(@as(T, 15) == sr_input_lut[15]);
    }
    print("\tpassed.\n", .{});
}

pub fn test_jacobsthal() !void {
    print("\t\t LUT jacobsthal\t\t...", .{});

    inline for (.{ u16, u32, u64, usize }) |T| {
        try std.testing.expectEqual(LUT.SR.jacobsthal(@as(T, 0)), @as(T, 0));
        try std.testing.expectEqual(LUT.SR.jacobsthal(@as(T, 1)), @as(T, 1));
        try std.testing.expectEqual(LUT.SR.jacobsthal(@as(T, 2)), @as(T, 1));
        try std.testing.expectEqual(LUT.SR.jacobsthal(@as(T, 3)), @as(T, 3));
        try std.testing.expectEqual(LUT.SR.jacobsthal(@as(T, 4)), @as(T, 5));
        try std.testing.expectEqual(LUT.SR.jacobsthal(@as(T, 5)), @as(T, 11));
        try std.testing.expectEqual(LUT.SR.jacobsthal(@as(T, 6)), @as(T, 21));
        try std.testing.expectEqual(LUT.SR.jacobsthal(@as(T, 7)), @as(T, 43));
        try std.testing.expectEqual(LUT.SR.jacobsthal(@as(T, 8)), @as(T, 85));
        try std.testing.expectEqual(LUT.SR.jacobsthal(@as(T, 9)), @as(T, 171));
        try std.testing.expectEqual(LUT.SR.jacobsthal(@as(T, 10)), @as(T, 341));
        try std.testing.expectEqual(LUT.SR.jacobsthal(@as(T, 11)), @as(T, 683));
        try std.testing.expectEqual(LUT.SR.jacobsthal(@as(T, 12)), @as(T, 1365));
        try std.testing.expectEqual(LUT.SR.jacobsthal(@as(T, 13)), @as(T, 2731));
        try std.testing.expectEqual(LUT.SR.jacobsthal(@as(T, 14)), @as(T, 5461));
    }
    print("\tpassed.\n", .{});
}

pub fn test_sr_sched_init() !void {
    print("\t\t LUT sr_sched_init\t...", .{});

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    inline for (.{ u16, u32, u64, usize }) |T| {
        var N: T = 32;
        var sr_sched_cnt = try allocator.alloc(T, 5);
        var sr_sched_off = try allocator.alloc(T, LUT.SR.jacobsthal(math.log2(N)) + 1);

        LUT.SR.sched_lut_init(T, N, sr_sched_cnt.ptr, sr_sched_off.ptr);

        try std.testing.expectEqual(sr_sched_cnt[0], @as(T, 11));
        try std.testing.expectEqual(sr_sched_cnt[1], @as(T, 5));
        try std.testing.expectEqual(sr_sched_cnt[2], @as(T, 3));
        try std.testing.expectEqual(sr_sched_cnt[3], @as(T, 1));
        try std.testing.expectEqual(sr_sched_cnt[4], @as(T, 1));

        try std.testing.expectEqual(sr_sched_off[0], @as(T, 0));
        try std.testing.expectEqual(sr_sched_off[1], @as(T, 2));
        try std.testing.expectEqual(sr_sched_off[2], @as(T, 3));
        try std.testing.expectEqual(sr_sched_off[3], @as(T, 4));
        try std.testing.expectEqual(sr_sched_off[4], @as(T, 6));
        try std.testing.expectEqual(sr_sched_off[5], @as(T, 8));
        try std.testing.expectEqual(sr_sched_off[6], @as(T, 10));
        try std.testing.expectEqual(sr_sched_off[7], @as(T, 11));
        try std.testing.expectEqual(sr_sched_off[8], @as(T, 12));
        try std.testing.expectEqual(sr_sched_off[9], @as(T, 14));
        try std.testing.expectEqual(sr_sched_off[10], @as(T, 15));
        try std.testing.expectEqual(sr_sched_off[11], @as(T, 32));
    }
    print("\tpassed.\n", .{});
}
