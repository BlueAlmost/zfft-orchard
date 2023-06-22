const std = @import("std");
const print = std.debug.print;

// ffts to be tested
const fft_desc = [_]FFTdescriptor{
    .{ .name = "reference_fft" },
    .{ .name = "cp_dit_bi_G_L_P" },
    .{ .name = "cp_dit_bi_G_L_S_P" },

    .{ .name = "cp_dit_bi_G_L" },
    .{ .name = "cp_dit_bi_L" },
    .{ .name = "cp_dit_bi_P" },
    .{ .name = "cp_dit_bi_S_P" },

    .{ .name = "cp_dit_di_P" },
    .{ .name = "cp_dit_di_S_P" },
    .{ .name = "cp_dit_di" },

    .{ .name = "cp_dit_dr_P" },
    .{ .name = "cp_dit_dr_S_P" },
    .{ .name = "cp_dit_dr" },

    .{ .name = "ct_dit_bi_G_P" },
    .{ .name = "ct_dit_bi_G_S_P" },
    .{ .name = "ct_dit_bi_G" },
    .{ .name = "ct_dit_bi_N" },
    .{ .name = "ct_dit_bi_P" },
    .{ .name = "ct_dit_bi_S_P" },
    .{ .name = "ct_dit_bi" },

    .{ .name = "ct_dit_dr_P" },
    .{ .name = "ct_dit_dr_S_P" },
    .{ .name = "ct_dit_dr" },

    .{ .name = "mr_dit_bi_G_P" },
    .{ .name = "mr_dit_bi_G_S_P" },
    .{ .name = "mr_dit_bi_G" },
    .{ .name = "mr_dit_bi_P" },
    .{ .name = "mr_dit_bi_S_P" },
    .{ .name = "mr_dit_bi" },

    .{ .name = "mr_dit_dr_P" },
    .{ .name = "mr_dit_dr_S_P" },
    .{ .name = "mr_dit_dr" },

    .{ .name = "sr_dit_bi_G_L_P" },
    .{ .name = "sr_dit_bi_G_L_S_P" },
    .{ .name = "sr_dit_bi_G_L" },
    .{ .name = "sr_dit_bi_G_P" },
    .{ .name = "sr_dit_bi_G" },
    .{ .name = "sr_dit_bi_L_P" },
    .{ .name = "sr_dit_bi_L_S_P" },
    .{ .name = "sr_dit_bi_L" },
    .{ .name = "sr_dit_bi_N_G" },

    .{ .name = "sr_dit_dr_P" },
    .{ .name = "sr_dit_dr_S_P" },
    .{ .name = "sr_dit_dr" },
};

const FFTdescriptor = struct {
    name: []const u8,

    pub fn configure(self: @This(), bb: *std.build.Builder, allo: std.mem.Allocator, list_test_verify_cmd: anytype, list_test_verify_exe: anytype, list_test_speed_cmd: anytype, list_test_speed_exe: anytype) !void {
        var src_file = try std.fmt.allocPrint(allo, "{s}{s}{s}", .{ "./test/ffts/", self.name, ".zig" });
        var test_name = try std.fmt.allocPrint(allo, "{s}", .{self.name});

        // We build TWO different versions of each fft, one is used for
        // verification of correctness, the other is used for timing of speed.
        // Each use the same source code, but a switch in fft test file based
        // on "build option" here in build.zig file enables production of the two.

        // Build for verification ----------------------
        const optimize_verify = std.builtin.OptimizeMode.Debug;
        const build_options_verify = bb.addOptions();
        build_options_verify.addOption(bool, "verify_only", true);

        const test_verify_exe = bb.addExecutable(.{
            .name = test_name,
            .root_source_file = .{ .path = src_file },
            .optimize = optimize_verify,
        });
        test_verify_exe.addOptions("build_options", build_options_verify);
        try list_test_verify_exe.append(test_verify_exe);

        const test_verify_cmd = bb.addRunArtifact(test_verify_exe);
        try list_test_verify_cmd.append(test_verify_cmd);

        // Build for speed benchmarking ----------------------
        const optimize_speed = std.builtin.OptimizeMode.ReleaseFast;
        const build_options_speed = bb.addOptions();
        build_options_speed.addOption(bool, "verify_only", false);

        const test_speed_exe = bb.addExecutable(.{
            .name = test_name,
            .root_source_file = .{ .path = src_file },
            .optimize = optimize_speed,
        });
        test_speed_exe.addOptions("build_options", build_options_speed);
        try list_test_speed_exe.append(test_speed_exe);

        const test_speed_cmd = bb.addRunArtifact(test_speed_exe);
        try list_test_speed_cmd.append(test_speed_cmd);
    }
};

pub fn build(b: *std.build.Builder) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Modules and their dependencies -------------------------- creates *Build.Module

    const type_helpers_mod = b.createModule(.{ .source_file = .{ .path = "src/type_helpers.zig" } });

    const bit_reverse_mod = b.createModule(.{ .source_file = .{ .path = "src/bit_reverse.zig" } });

    const complex_math_mod = b.createModule(.{
        .source_file = .{ .path = "src/complex_math.zig" },
        .dependencies = &.{.{ .name = "type_helpers", .module = type_helpers_mod }},
    });

    const butterflies_mod = b.createModule(.{ .source_file = .{ .path = "src/butterflies.zig" }, .dependencies = &.{
        .{ .name = "type_helpers", .module = type_helpers_mod },
        .{ .name = "complex_math", .module = complex_math_mod },
    } });

    const twiddles_mod = b.createModule(.{ .source_file = .{ .path = "src/Twiddles.zig" }, .dependencies = &.{.{ .name = "type_helpers", .module = type_helpers_mod }} });

    const lut_mod = b.createModule(.{ .source_file = .{ .path = "src/LUT.zig" } });

    const fft_mod = b.createModule(.{ .source_file = .{ .path = "src/FFT.zig" }, .dependencies = &.{
        .{ .name = "type_helpers", .module = type_helpers_mod },
        .{ .name = "bit_reverse", .module = bit_reverse_mod },
        .{ .name = "complex_math", .module = complex_math_mod },
        .{ .name = "butterflies", .module = butterflies_mod },
        .{ .name = "LUT", .module = lut_mod },
        .{ .name = "Twiddles", .module = twiddles_mod },
    } });

    const config_mod = b.createModule(.{ .source_file = .{ .path = "Config.zig" } });

    const bench_mod = b.createModule(.{ .source_file = .{ .path = "src/Bench.zig" }, .dependencies = &.{
        .{ .name = "type_helpers", .module = type_helpers_mod },
        .{ .name = "FFT", .module = fft_mod },
        .{ .name = "Config", .module = config_mod },
    } });

    // TEST Executables ----------------------------- creates *Build.Step.Compile
    // even though these will be run as tests, we still invoke the "b.addExecutable"
    // since if "addTest" is used, then we do not get the std.debug.print on screen.

    const type_helpers_exe = b.addExecutable(.{
        .name = "type_helpers",
        .root_source_file = .{ .path = "test/type_helpers.zig" },
        .target = target,
        .optimize = optimize,
    });

    const bit_reverse_exe = b.addExecutable(.{
        .name = "bit_reverse",
        .root_source_file = .{ .path = "test/bit_reverse.zig" },
        .target = target,
        .optimize = optimize,
    });

    const complex_math_exe = b.addExecutable(.{
        .name = "complex_math",
        .root_source_file = .{ .path = "test/complex_math.zig" },
        .target = target,
        .optimize = optimize,
    });

    const butterflies_exe = b.addExecutable(.{
        .name = "butterflies",
        .root_source_file = .{ .path = "test/butterflies.zig" },
        .target = target,
        .optimize = optimize,
    });

    const twiddles_exe = b.addExecutable(.{
        .name = "twiddles",
        .root_source_file = .{ .path = "test/twiddles.zig" },
        .target = target,
        .optimize = optimize,
    });

    const lut_exe = b.addExecutable(.{
        .name = "lut",
        .root_source_file = .{ .path = "test/lut.zig" },
        .target = target,
        .optimize = optimize,
    });

    // Run Artifacts, their modules and installation --------this creates *Build.Step.Run

    type_helpers_exe.addModule("type_helpers", type_helpers_mod);
    const type_helpers_cmd = b.addRunArtifact(type_helpers_exe);

    bit_reverse_exe.addModule("bit_reverse", bit_reverse_mod);
    const bit_reverse_cmd = b.addRunArtifact(bit_reverse_exe);

    complex_math_exe.addModule("complex_math", complex_math_mod);
    const complex_math_cmd = b.addRunArtifact(complex_math_exe);

    butterflies_exe.addModule("butterflies", butterflies_mod);
    const butterflies_cmd = b.addRunArtifact(butterflies_exe);

    twiddles_exe.addModule("Twiddles", twiddles_mod);
    const twiddles_cmd = b.addRunArtifact(twiddles_exe);

    lut_exe.addModule("LUT", lut_mod);
    const lut_cmd = b.addRunArtifact(lut_exe);

    // FFT --------------------------------------------------

    var list_test_verify_exe = std.ArrayList(*std.Build.Step.Compile).init(allocator);
    var list_test_verify_cmd = std.ArrayList(*std.Build.Step.Run).init(allocator);

    var list_test_speed_exe = std.ArrayList(*std.Build.Step.Compile).init(allocator);
    var list_test_speed_cmd = std.ArrayList(*std.Build.Step.Run).init(allocator);

    for (fft_desc) |fft| {
        try fft.configure(
            b,
            allocator,
            &list_test_verify_cmd,
            &list_test_verify_exe,
            &list_test_speed_cmd,
            &list_test_speed_exe,
        );
    }

    for (list_test_verify_exe.items) |item| {
        item.addModule("type_helpers", type_helpers_mod);
        item.addModule("Bench", bench_mod);
        item.addModule("bit_reverse", bit_reverse_mod);
        item.addModule("complex_math", complex_math_mod);
        item.addModule("butterflies", butterflies_mod);
        item.addModule("Twiddles", twiddles_mod);
        item.addModule("LUT", lut_mod);
        item.addModule("FFT", fft_mod);
    }

    // Note: the verification code is NOT installed in the zig-out directory

    for (list_test_speed_exe.items) |item| {
        item.addModule("type_helpers", type_helpers_mod);
        item.addModule("Bench", bench_mod);
        item.addModule("bit_reverse", bit_reverse_mod);
        item.addModule("complex_math", complex_math_mod);
        item.addModule("butterflies", butterflies_mod);
        item.addModule("Twiddles", twiddles_mod);
        item.addModule("LUT", lut_mod);
        item.addModule("FFT", fft_mod);
    }

    // b.installArtifact(...) declares intent for executable to be installed
    // in the standard location via "zig build"
    for (list_test_speed_exe.items) |item| {
        b.installArtifact(item);
    }

    // Cascade cmd dependencies (to avoid interlaced printouts) ------------------

    bit_reverse_cmd.step.dependOn(&type_helpers_cmd.step);
    complex_math_cmd.step.dependOn(&bit_reverse_cmd.step);
    butterflies_cmd.step.dependOn(&complex_math_cmd.step);
    twiddles_cmd.step.dependOn(&butterflies_cmd.step);
    lut_cmd.step.dependOn(&twiddles_cmd.step);

    for (list_test_verify_exe.items, 0..) |_, i| {
        if (i == 0) {
            list_test_verify_exe.items[i].step.dependOn(&lut_cmd.step);
        } else {
            list_test_verify_exe.items[i].step.dependOn(&list_test_verify_exe.items[i - 1].step);
        }
    }

    // Construct verification test steps ------------------------------------------------------

    const test_verify_step = b.step("test", "Run unit tests");

    test_verify_step.dependOn(&type_helpers_cmd.step);
    test_verify_step.dependOn(&bit_reverse_cmd.step);
    test_verify_step.dependOn(&complex_math_cmd.step);
    test_verify_step.dependOn(&butterflies_cmd.step);
    test_verify_step.dependOn(&twiddles_cmd.step);
    test_verify_step.dependOn(&lut_cmd.step);

    for (list_test_verify_cmd.items, 0..) |_, i| {
        test_verify_step.dependOn(&list_test_verify_cmd.items[i].step);
    }
    // Construct speed test steps ------------------------------------------------------

    const test_speed_step = b.step("speed", "Run speed tests");

    for (list_test_speed_cmd.items, 0..) |_, i| {
        test_speed_step.dependOn(&list_test_speed_cmd.items[i].step);
    }
}
