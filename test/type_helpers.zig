const std = @import("std");
const Complex = std.math.Complex;
const print = std.debug.print;

const ValueType = @import("type_helpers").ValueType;
const ElementType = @import("type_helpers").ElementType;
const isComplex = @import("type_helpers").isComplex;

pub fn main() !void {
    print("\n\ttesting type_helpers:\n", .{});

    print("\t\t ValueType \t\t...", .{});
    try std.testing.expect(ValueType(f32) == f32);
    try std.testing.expect(ValueType(Complex(f32)) == f32);
    try std.testing.expect(ValueType([]f32) == f32);
    try std.testing.expect(ValueType([]Complex(f32)) == f32);

    try std.testing.expect(ValueType(f64) == f64);
    try std.testing.expect(ValueType(Complex(f64)) == f64);
    try std.testing.expect(ValueType([]f64) == f64);
    try std.testing.expect(ValueType([]Complex(f64)) == f64);
    print("\tpassed.\n", .{});

    print("\t\t ElementType \t\t...", .{});
    try std.testing.expect(ElementType([]f32) == f32);
    try std.testing.expect(ElementType([]f64) == f64);
    try std.testing.expect(ElementType([]Complex(f32)) == Complex(f32));
    try std.testing.expect(ElementType([]Complex(f64)) == Complex(f64));
    print("\tpassed.\n", .{});

    print("\t\t isComplex \t\t...", .{});
    try std.testing.expect(isComplex(f32) == false);
    try std.testing.expect(isComplex(f64) == false);
    try std.testing.expect(isComplex([]f32) == false);
    try std.testing.expect(isComplex([]f64) == false);

    try std.testing.expect(isComplex(Complex(f32)) == true);
    try std.testing.expect(isComplex(Complex(f64)) == true);
    try std.testing.expect(isComplex([]Complex(f32)) == true);
    try std.testing.expect(isComplex([]Complex(f64)) == true);
    print("\tpassed.\n", .{});
}
