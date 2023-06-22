const std = @import("std");
const Complex = std.math.Complex;
const print = std.debug.print;

const eps = 1e-6;

// Unary Operations,  for complex number x
// =========================================

//  neg(x)         -x
//  negI(x)        -i*x
//  negIConj(x)    -i*conj(x)

//  posI(x)         i*x
//  iConj(x)        i*conj(x)

//  conj(x)        conjugate of x
//  conjNeg        -conj(x)
//  conjI(x)       conj(i*x)
//  conjNegI(x)    -conj(i*x) = conj(-i*x)

//  scale(x)       beta*x  (where beta is a real)

// Binary Operations,  for complex numbers x and y
// ================================================

// add(x, y)      x+y
// addI(x, y)     x+i*y
// addConj(x, y)  x+conj(y)
// addConjI(x, y) x+conj(i*y)

// sub(x, y)      x-y
// subI(x, y)     x-i*y
// subConj(x, y)  x-conj(y)
// subConjI(x, y) x-conj(i*y)

// mul(x, y)      x*y
// mulI(x,y)      x*(i*y)
// mulNeg(x,y)    x*(-y)
// mulNegI(x,y)   x*(-i*y)

// mulConj(x,y)   x*conj(y)
// mulConjI(x,y)  x*conj(i*y)

// div(x, y)      x/y

pub inline fn neg(a: anytype) @TypeOf(a) {
    // returns -x
    return @TypeOf(a).init(-a.re, -a.im);
}

pub inline fn negI(a: anytype) @TypeOf(a) {
    // returns -i*x
    return @TypeOf(a).init(a.im, -a.re);
}

pub inline fn negIConj(a: anytype) @TypeOf(a) {
    // returns -i*conj(x)
    return @TypeOf(a).init(-a.im, -a.re);
}

pub inline fn posI(a: anytype) @TypeOf(a) {
    // returns i*x
    return @TypeOf(a).init(-a.im, a.re);
}

pub inline fn posIConj(a: anytype) @TypeOf(a) {
    // returns i*conj(x)
    return @TypeOf(a).init(a.im, a.re);
}

pub inline fn conj(a: anytype) @TypeOf(a) {
    // returns conjugate of x
    return @TypeOf(a).init(a.re, -a.im);
}

pub inline fn conjNeg(a: anytype) @TypeOf(a) {
    // returns conj(-x)
    return @TypeOf(a).init(-a.re, a.im);
}

pub inline fn conjI(a: anytype) @TypeOf(a) {
    // returns conj(i*x)
    return @TypeOf(a).init(-a.im, -a.re);
}

pub inline fn conjNegI(a: anytype) @TypeOf(a) {
    // returns conj(-i*x)
    return @TypeOf(a).init(a.im, a.re);
}

pub inline fn scale(a: anytype, beta: @TypeOf(a.re)) @TypeOf(a) {
    // returns a*beta (where beta is a real number)
    return @TypeOf(a).init(beta * a.re, beta * a.im);
}

// Binary Operations -----------------------------------------------

pub inline fn add(a: anytype, b: @TypeOf(a)) @TypeOf(a) {
    // returns a+b
    return @TypeOf(a).init(a.re + b.re, a.im + b.im);
}

pub inline fn addI(a: anytype, b: @TypeOf(a)) @TypeOf(a) {
    // returns a+ib
    return @TypeOf(a).init(a.re - b.im, a.im + b.re);
}

pub inline fn addConj(a: anytype, b: @TypeOf(a)) @TypeOf(a) {
    // returns a+conj(b)
    return @TypeOf(a).init(a.re + b.re, a.im - b.im);
}

pub inline fn addConjI(a: anytype, b: @TypeOf(a)) @TypeOf(a) {
    // returns a+conj(ib)
    return @TypeOf(a).init(a.re - b.im, a.im - b.re);
}

pub inline fn sub(a: anytype, b: @TypeOf(a)) @TypeOf(a) {
    // returns a-b
    return @TypeOf(a).init(a.re - b.re, a.im - b.im);
}

pub inline fn subI(a: anytype, b: @TypeOf(a)) @TypeOf(a) {
    // returns a-ib
    return @TypeOf(a).init(a.re + b.im, a.im - b.re);
}

pub inline fn subConj(a: anytype, b: @TypeOf(a)) @TypeOf(a) {
    // returns a-conj(b)
    return @TypeOf(a).init(a.re - b.re, a.im + b.im);
}

pub inline fn subConjI(a: anytype, b: @TypeOf(a)) @TypeOf(a) {
    // returns a-conj(ib)
    return @TypeOf(a).init(a.re + b.im, a.im + b.re);
}

pub inline fn mul(a: anytype, b: @TypeOf(a)) @TypeOf(a) {
    // returns a*b
    return @TypeOf(a).init(a.re * b.re - a.im * b.im, a.re * b.im + a.im * b.re);
}

pub inline fn mulI(a: anytype, b: @TypeOf(a)) @TypeOf(a) {
    // returns a*i*b
    return @TypeOf(a).init(-a.re * b.im - a.im * b.re, a.re * b.re - a.im * b.im);
}

pub inline fn mulNeg(a: anytype, b: @TypeOf(a)) @TypeOf(a) {
    // returns -a*b
    return @TypeOf(a).init(-a.re * b.re + a.im * b.im, -a.re * b.im - a.im * b.re);
}

pub inline fn mulNegI(a: anytype, b: @TypeOf(a)) @TypeOf(a) {
    // returns -a*i*b
    return @TypeOf(a).init(a.re * b.im + a.im * b.re, -a.re * b.re + a.im * b.im);
}

pub inline fn mulConj(a: anytype, b: @TypeOf(a)) @TypeOf(a) {
    // returns a*conj(b)
    return @TypeOf(a).init(a.re * b.re + a.im * b.im, -a.re * b.im + a.im * b.re);
}

pub inline fn mulConjI(a: anytype, b: @TypeOf(a)) @TypeOf(a) {
    // returns a*conj(ib)
    return @TypeOf(a).init(-a.re * b.im + a.im * b.re, -a.re * b.re - a.im * b.im);
}

pub inline fn div(a: anytype, b: @TypeOf(a)) @TypeOf(a) {
    var den: @TypeOf(a.re) = b.re * b.re + b.im * b.im;

    return @TypeOf(a).init((a.re * b.re + a.im * b.im) / den, (a.im * b.re - a.re * b.im) / den);
}
