const std = @import("std");
const Complex = std.math.Complex;
const print = std.debug.print;

// unary ---------------------------------------------------------------
const neg = @import("complex_math").neg;
const negI = @import("complex_math").negI;
const negIConj = @import("complex_math").negIConj;
const posI = @import("complex_math").posI;
const posIConj = @import("complex_math").posIConj;
const conj = @import("complex_math").conj;
const conjNeg = @import("complex_math").conjNeg;
const conjI = @import("complex_math").conjI;
const conjNegI = @import("complex_math").conjNegI;
const scale = @import("complex_math").scale;

// binary ---------------------------------------------------------------
const add = @import("complex_math").add;
const addI = @import("complex_math").addI;
const addConj = @import("complex_math").addConj;
const addConjI = @import("complex_math").addConjI;

const sub = @import("complex_math").sub;
const subI = @import("complex_math").subI;
const subConj = @import("complex_math").subConj;
const subConjI = @import("complex_math").subConjI;

const mul = @import("complex_math").mul;
const mulI = @import("complex_math").mulI;
const mulNeg = @import("complex_math").mulNeg;
const mulNegI = @import("complex_math").mulNegI;
const mulConj = @import("complex_math").mulConj;
const mulConjI = @import("complex_math").mulConjI;

const div = @import("complex_math").div;

const eps = 1e-6;

pub fn main() !void {
    print("\n\ttesting complex_math:\n", .{});

    const C = Complex(f64);
    var a: C = undefined;
    var b: C = undefined;
    var c: C = undefined;
    var beta: f64 = undefined;

    // unary ---------------------------------------------------------------
    print("\t\t neg \t\t... ", .{});
    a = C.init(1.0, 2.0);
    c = neg(a);
    try std.testing.expectApproxEqAbs(c.re, -1.0, eps);
    try std.testing.expectApproxEqAbs(c.im, -2.0, eps);
    print("\tpassed.\n", .{});

    print("\t\t negI \t\t... ", .{});
    a = C.init(1.0, 2.0);
    c = negI(a);
    try std.testing.expectApproxEqAbs(c.re, 2.0, eps);
    try std.testing.expectApproxEqAbs(c.im, -1.0, eps);
    print("\tpassed.\n", .{});

    print("\t\t negIConj \t... ", .{});
    a = C.init(1.0, 2.0);
    c = negIConj(a);
    try std.testing.expectApproxEqAbs(c.re, -2.0, eps);
    try std.testing.expectApproxEqAbs(c.im, -1.0, eps);
    print("\tpassed.\n", .{});

    print("\t\t posI \t\t... ", .{});
    a = C.init(1.0, 2.0);
    c = posI(a);
    try std.testing.expectApproxEqAbs(c.re, -2.0, eps);
    try std.testing.expectApproxEqAbs(c.im, 1.0, eps);
    print("\tpassed.\n", .{});

    print("\t\t posIConj \t... ", .{});
    a = C.init(1.0, 2.0);
    c = posIConj(a);
    try std.testing.expectApproxEqAbs(c.re, 2.0, eps);
    try std.testing.expectApproxEqAbs(c.im, 1.0, eps);
    print("\tpassed.\n", .{});

    print("\t\t conj \t\t... ", .{});
    a = C.init(1.0, 2.0);
    c = conj(a);
    try std.testing.expectApproxEqAbs(c.re, 1.0, eps);
    try std.testing.expectApproxEqAbs(c.im, -2.0, eps);
    print("\tpassed.\n", .{});

    print("\t\t conjNeg \t... ", .{});
    a = C.init(1.0, 2.0);
    c = conjNeg(a);
    try std.testing.expectApproxEqAbs(c.re, -1.0, eps);
    try std.testing.expectApproxEqAbs(c.im, 2.0, eps);
    print("\tpassed.\n", .{});

    print("\t\t conjI \t\t... ", .{});
    a = C.init(1.0, 2.0);
    c = conjI(a);
    try std.testing.expectApproxEqAbs(c.re, -2.0, eps);
    try std.testing.expectApproxEqAbs(c.im, -1.0, eps);
    print("\tpassed.\n", .{});

    print("\t\t conjNegI \t... ", .{});
    a = C.init(1.0, 2.0);
    c = conjNegI(a);
    try std.testing.expectApproxEqAbs(c.re, 2.0, eps);
    try std.testing.expectApproxEqAbs(c.im, 1.0, eps);
    print("\tpassed.\n", .{});

    print("\t\t scale \t\t... ", .{});
    a = C.init(1.0, 2.0);
    beta = 3.0;
    c = scale(a, beta);

    try std.testing.expectApproxEqAbs(c.re, 3.0, eps);
    try std.testing.expectApproxEqAbs(c.im, 6.0, eps);
    print("\tpassed.\n", .{});

    // Binary Tests -----------------------------------------------

    print("\t\t add \t\t... ", .{});
    a = C.init(1.0, 2.0);
    b = C.init(0.1, 0.2);
    c = add(a, b);
    try std.testing.expectApproxEqAbs(c.re, 1.1, eps);
    try std.testing.expectApproxEqAbs(c.im, 2.2, eps);
    print("\tpassed.\n", .{});

    print("\t\t addI \t\t... ", .{});
    a = C.init(1.0, 2.0);
    b = C.init(0.1, 0.2);
    c = addI(a, b);
    try std.testing.expectApproxEqAbs(c.re, 0.8, eps);
    try std.testing.expectApproxEqAbs(c.im, 2.1, eps);
    print("\tpassed.\n", .{});

    print("\t\t addConj \t... ", .{});
    a = C.init(1.0, 2.0);
    b = C.init(0.1, 0.2);
    c = addConj(a, b);
    try std.testing.expectApproxEqAbs(c.re, 1.1, eps);
    try std.testing.expectApproxEqAbs(c.im, 1.8, eps);
    print("\tpassed.\n", .{});

    print("\t\t addConjI \t... ", .{});
    a = C.init(1.0, 2.0);
    b = C.init(0.1, 0.2);
    c = addConjI(a, b);
    try std.testing.expectApproxEqAbs(c.re, 0.8, eps);
    try std.testing.expectApproxEqAbs(c.im, 1.9, eps);
    print("\tpassed.\n", .{});

    print("\t\t sub \t\t... ", .{});
    a = C.init(1.0, 2.0);
    b = C.init(0.1, 0.2);
    c = sub(a, b);
    try std.testing.expectApproxEqAbs(c.re, 0.9, eps);
    try std.testing.expectApproxEqAbs(c.im, 1.8, eps);
    print("\tpassed.\n", .{});

    print("\t\t subI \t\t... ", .{});
    a = C.init(1.0, 2.0);
    b = C.init(0.1, 0.2);
    c = subI(a, b);
    try std.testing.expectApproxEqAbs(c.re, 1.2, eps);
    try std.testing.expectApproxEqAbs(c.im, 1.9, eps);
    print("\tpassed.\n", .{});

    print("\t\t subConj \t... ", .{});
    a = C.init(1.0, 2.0);
    b = C.init(0.1, 0.2);
    c = subConj(a, b);
    try std.testing.expectApproxEqAbs(c.re, 0.9, eps);
    try std.testing.expectApproxEqAbs(c.im, 2.2, eps);
    print("\tpassed.\n", .{});

    print("\t\t subConjI \t... ", .{});
    a = C.init(1.0, 2.0);
    b = C.init(0.1, 0.2);
    c = subConjI(a, b);
    try std.testing.expectApproxEqAbs(c.re, 1.2, eps);
    try std.testing.expectApproxEqAbs(c.im, 2.1, eps);
    print("\tpassed.\n", .{});

    print("\t\t mul \t\t... ", .{});
    a = C.init(1.0, 2.0);
    b = C.init(-1.1, 2.6);
    c = mul(a, b);
    try std.testing.expectApproxEqAbs(c.re, -6.3, eps);
    try std.testing.expectApproxEqAbs(c.im, 0.40, eps);
    print("\tpassed.\n", .{});

    print("\t\t mulI \t\t... ", .{});
    a = C.init(1.0, 2.0);
    b = C.init(-1.1, 2.6);
    c = mulI(a, b);
    try std.testing.expectApproxEqAbs(c.re, -0.4, eps);
    try std.testing.expectApproxEqAbs(c.im, -6.3, eps);
    print("\tpassed.\n", .{});

    print("\t\t mulNeg \t... ", .{});
    a = C.init(1.0, 2.0);
    b = C.init(-1.1, 2.6);
    c = mulNeg(a, b);
    try std.testing.expectApproxEqAbs(c.re, 6.3, eps);
    try std.testing.expectApproxEqAbs(c.im, -0.4, eps);
    print("\tpassed.\n", .{});

    print("\t\t mulNegI \t... ", .{});
    a = C.init(1.0, 2.0);
    b = C.init(-1.1, 2.6);
    c = mulNegI(a, b);
    try std.testing.expectApproxEqAbs(c.re, 0.4, eps);
    try std.testing.expectApproxEqAbs(c.im, 6.3, eps);
    print("\tpassed.\n", .{});

    print("\t\t mulConj \t... ", .{});
    a = C.init(1.0, 2.0);
    b = C.init(-1.1, 2.6);
    c = mulConj(a, b);
    try std.testing.expectApproxEqAbs(c.re, 4.1, eps);
    try std.testing.expectApproxEqAbs(c.im, -4.8, eps);
    print("\tpassed.\n", .{});

    print("\t\t mulConjI \t... ", .{});
    a = C.init(1.0, 2.0);
    b = C.init(-1.1, 2.6);
    c = mulConjI(a, b);
    try std.testing.expectApproxEqAbs(c.re, -4.8, eps);
    try std.testing.expectApproxEqAbs(c.im, -4.1, eps);
    print("\tpassed.\n", .{});

    print("\t\t div \t\t... ", .{});
    a = C.init(1.0, 2.0);
    b = C.init(-1.1, 2.2);
    c = div(a, b);
    try std.testing.expectApproxEqAbs(c.re, 0.54545454, eps);
    try std.testing.expectApproxEqAbs(c.im, -0.72727272, eps);
    print("\tpassed.\n", .{});
}
