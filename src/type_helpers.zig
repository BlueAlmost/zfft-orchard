const std = @import("std");
const Complex = std.math.Complex;

pub fn ValueType(comptime T: type) type {
    switch (T) {
        f32, Complex(f32), []f32, []Complex(f32) => {
            return f32;
        },
        f64, Complex(f64), []f64, []Complex(f64) => {
            return f64;
        },
        else => {
            @compileError("type not implemented");
        },
    }
}

pub fn ElementType(comptime T: type) type {
    switch (T) {
        []f32 => {
            return f32;
        },
        []f64 => {
            return f64;
        },
        []Complex(f32) => {
            return Complex(f32);
        },
        []Complex(f64) => {
            return Complex(f64);
        },
        else => {
            @compileError("type not implemented");
        },
    }
}

pub fn isComplex(comptime T: type) bool {
    switch (T) {
        f32, f64, []f32, []f64 => {
            return false;
        },
        Complex(f32), Complex(f64), []Complex(f32), []Complex(f64) => {
            return true;
        },
        else => {
            @compileError("type not implemented");
        },
    }
}
