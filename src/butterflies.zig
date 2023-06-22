const std = @import("std");
const math = std.math;
const Complex = std.math.Complex;
const print = std.debug.print;

const ValueType = @import("type_helpers").ValueType;

const add = @import("complex_math").add;
const addI = @import("complex_math").addI;
const posI = @import("complex_math").posI;
const negI = @import("complex_math").negI;
const sub = @import("complex_math").sub;
const subI = @import("complex_math").subI;
const mul = @import("complex_math").mul;
const mulConj = @import("complex_math").mulConj;
const mulI = @import("complex_math").mulI;
const scale = @import("complex_math").scale;

// ...............................................................................
// Butterflies for the conjugate pair FFT

pub fn cp_dit_bf(comptime C: type, s: usize, out: [*]C, w: C) void {

    // const T = ValueType(C);

    const a: C = out[0];
    const b: C = out[s];
    const c: C = out[s * 2];
    const d: C = out[s * 3];

    const alpha = mul(w, c);
    const beta = mulConj(d, w);

    // out[0] = a + (w * c + conj(w) * d)
    out[0] = add(a, add(alpha, beta));

    // out[s] = b - I * (w * c - conj(w) * d)
    out[s] = subI(b, sub(alpha, beta));

    // out[s * 2] = a - (w * c + conj(w) * d)
    out[s * 2] = sub(a, add(alpha, beta));

    // out[s * 3] = b + I * (w * c - conj(w) * d)
    out[s * 3] = addI(b, sub(alpha, beta));
}

pub fn cp_dit_bf_pi4(comptime C: type, s: usize, out: [*]C) void {
    const T = ValueType(C);

    const a = out[0];
    const b = out[s];
    const c = out[s * 2];
    const d = out[s * 3];

    const rc: T = math.sqrt1_2 * c.re;
    const ic: T = math.sqrt1_2 * c.im;

    const rd: T = math.sqrt1_2 * d.re;
    const id: T = math.sqrt1_2 * d.im;

    const wcr: T = ic + rc;
    const wci: T = ic - rc;

    const cwdr: T = rd - id;
    const cwdi: T = rd + id;

    const rsu: T = wcr + cwdr;
    const isu: T = wci + cwdi;

    const rsb: T = wcr - cwdr;
    const isb: T = wci - cwdi;

    out[0].re = a.re + rsu;
    out[0].im = a.im + isu;

    out[s].re = b.re + isb;
    out[s].im = b.im - rsb;

    out[s * 2].re = a.re - rsu;
    out[s * 2].im = a.im - isu;

    out[s * 3].re = b.re - isb;
    out[s * 3].im = b.im + rsb;
}

pub fn cp_dit_bf_0(comptime C: type, s: usize, out: [*]C) void {
    const T = ValueType(C);

    const a: C = out[0];
    const b: C = out[s];
    const c: C = out[s * 2];
    const d: C = out[s * 3];

    const rsu: T = c.re + d.re;
    const rsb: T = c.re - d.re;

    const isu: T = c.im + d.im;
    const isb: T = c.im - d.im;

    out[0].re = a.re + rsu;
    out[0].im = a.im + isu;

    out[s].re = b.re + isb;
    out[s].im = b.im - rsb;

    out[s * 2].re = a.re - rsu;
    out[s * 2].im = a.im - isu;

    out[s * 3].re = b.re - isb;
    out[s * 3].im = b.im + rsb;
}

// --------------------------------------------------------------------------------
// Butterflies for the radix 2 Cooley-Tukey FFT

pub fn ct_dit_bf2_0(comptime C: type, so: usize, si: usize, out: [*]C, in: [*]C) void {
    const a: C = in[0];
    const b: C = in[si];

    out[0] = add(a, b);
    out[so] = sub(a, b);
}

pub fn ct_dit_bf2_pi4(comptime C: type, s: usize, out: [*]C) void {
    const a: C = out[0];
    const b: C = out[s];

    const t = C.init(math.sqrt1_2 * (b.re + b.im), math.sqrt1_2 * (b.im - b.re));

    out[0] = add(a, t);
    out[s] = sub(a, t);
}

pub fn ct_dit_bf2_3pi4(comptime C: type, s: usize, out: [*]C) void {
    const a: C = out[0];
    const b: C = out[s];

    const t = C.init(math.sqrt1_2 * (-b.re + b.im), math.sqrt1_2 * (-b.im - b.re));

    out[0] = add(a, t);
    out[s] = sub(a, t);
}

pub fn ct_dit_bf2_pi2(comptime C: type, s: usize, out: [*]C) void {
    const a: C = out[0];
    const b: C = out[s];

    const t = C.init(b.im, -b.re);

    out[0] = add(a, t);
    out[s] = sub(a, t);
}

pub fn ct_dit_bf2(comptime C: type, s: usize, out: [*]C, w: C) void {
    const a = out[0];

    const b = mul(out[s], w);

    out[0] = add(a, b);
    out[s] = sub(a, b);
}

pub fn ct_dif_bf2_0(comptime C: type, so: usize, si: usize, out: [*]C, in: [*]C) void {
    const a = in[0];
    const b = in[si];

    out[0] = add(a, b);
    out[so] = sub(a, b);
}

pub fn ct_dif_bf2(comptime C: type, s: usize, out: [*]C, w: C) void {
    const a = out[0];
    const b = out[s];

    const alpha = sub(a, b);

    out[0] = add(a, b);
    out[s] = mul(alpha, w);
}

// ----------------------------------------------------------------------------
// Radix-4 butterflies for the mixed radix FFT

pub fn mr_dit_bf4_0(comptime C: type, so: usize, si: usize, out: [*]C, in: [*]C) void {
    const a: C = in[0];
    const b: C = in[si];
    const c: C = in[si * 2];
    const d: C = in[si * 3];

    const e = add(a, c);
    const f = sub(a, c);
    const g = add(b, d);
    const j = posI(sub(b, d));

    out[0] = add(e, g);
    out[so] = sub(f, j);
    out[so * 2] = sub(e, g);
    out[so * 3] = add(f, j);
}

pub fn mr_dit_bf4_1(comptime C: type, s: usize, out: [*]C) void {
    const a = out[0];
    const c = negI(out[s * 2]);

    const b_tmp = scale(out[s], math.sqrt1_2);
    const d_tmp = scale(out[s * 3], math.sqrt1_2);

    const b = C.init(b_tmp.im + b_tmp.re, b_tmp.im - b_tmp.re);
    const d = C.init(d_tmp.im - d_tmp.re, -d_tmp.im - d_tmp.re);

    const e = add(a, c);
    const f = sub(a, c);
    const g = add(b, d);
    const j = posI(sub(b, d));

    out[0] = add(e, g);
    out[s] = sub(f, j);
    out[s * 2] = sub(e, g);
    out[s * 3] = add(f, j);
}

pub fn mr_dit_bf4(comptime C: type, s: usize, out: [*]C, w1: C, w2: C, w3: C) void {
    const a = out[0];
    const b = mul(out[s], w1);
    const c = mul(out[s * 2], w2);
    const d = mul(out[s * 3], w3);

    const e = add(a, c);
    const f = sub(a, c);
    const g = add(b, d);
    const j = posI(sub(b, d));

    out[0] = add(e, g);
    out[s] = sub(f, j);
    out[s * 2] = sub(e, g);
    out[s * 3] = add(f, j);
}

// --------------------------------------------------------------------------------
// Butterflies for the split-radix FFT

pub fn sr_dit_bf4(comptime C: type, s: usize, out: [*]C, w1: C, w3: C) void {
    const T = ValueType(C);

    const a: C = out[0];
    const b: C = out[s];
    const c: C = out[s * 2];
    const d: C = out[s * 3];

    const w1c_re: T = w1.re * c.re - w1.im * c.im;
    const w1c_im: T = w1.re * c.im + w1.im * c.re;

    const w3d_re: T = w3.re * d.re - w3.im * d.im;
    const w3d_im: T = w3.re * d.im + w3.im * d.re;

    // out[0]     = a +     (w1 * c + w3 * d);
    out[0].re = a.re + (w1c_re + w3d_re);
    out[0].im = a.im + (w1c_im + w3d_im);

    // out[s]     = b - I * (w1 * c - w3 * d);
    out[s].re = b.re + (w1c_im - w3d_im);
    out[s].im = b.im - (w1c_re - w3d_re);

    // out[s * 2] = a -     (w1 * c + w3 * d);
    out[s * 2].re = a.re - (w1c_re + w3d_re);
    out[s * 2].im = a.im - (w1c_im + w3d_im);

    // out[s * 3] = b + I * (w1 * c - w3 * d);
    out[s * 3].re = b.re + (-w1c_im + w3d_im);
    out[s * 3].im = b.im + (w1c_re - w3d_re);
}

pub fn sr_dit_bf4_pi4(comptime C: type, s: usize, out: [*]C) void {
    const T = ValueType(C);

    const a: C = out[0];
    const b: C = out[s];
    const c: C = out[s * 2];
    const d: C = out[s * 3];

    // double rc   = M_SQRT1_2 * creal(c);
    const rc: T = math.sqrt1_2 * c.re;

    // double rd   = M_SQRT1_2 * creal(d);
    const rd: T = math.sqrt1_2 * d.re;

    // double ic   = M_SQRT1_2 * cimag(c);
    const ic: T = math.sqrt1_2 * c.im;

    // double id   = M_SQRT1_2 * cimag(d);
    const id: T = math.sqrt1_2 * d.im;

    // double wcr  = ic + rc;
    const wcr: T = ic + rc;

    // double wci  = ic - rc;
    const wci: T = ic - rc;

    // double wdr  = -rd + id;
    const wdr: T = -rd + id;

    // double wdi  = -rd - id;
    const wdi: T = -rd - id;

    // double rsu  = wcr + wdr;
    const rsu: T = wcr + wdr;

    // double rsb  = wcr - wdr;
    const rsb: T = wcr - wdr;

    // double isu  = wci + wdi;
    const isu: T = wci + wdi;

    // double isb  = wci - wdi;
    const isb: T = wci - wdi;

    // out[0]     = CMPLX(creal(a) + rsu, cimag(a) + isu);
    out[0].re = a.re + rsu;
    out[0].im = a.im + isu;

    // out[s]     = CMPLX(creal(b) + isb, cimag(b) - rsb);
    out[s].re = b.re + isb;
    out[s].im = b.im - rsb;

    // out[s * 2] = CMPLX(creal(a) - rsu, cimag(a) - isu);
    out[s * 2].re = a.re - rsu;
    out[s * 2].im = a.im - isu;

    // out[s * 3] = CMPLX(creal(b) - isb, cimag(b) + rsb);
    out[s * 3].re = b.re - isb;
    out[s * 3].im = b.im + rsb;
}

pub fn sr_dit_bf4_0(comptime C: type, s: usize, out: [*]C) void {
    const T = ValueType(C);

    const a: C = out[0];
    const b: C = out[s];
    const c: C = out[s * 2];
    const d: C = out[s * 3];

    const rsu: T = c.re + d.re;
    const rsb: T = c.re - d.re;
    const isu: T = c.im + d.im;
    const isb: T = c.im - d.im;

    out[0] = C.init(a.re + rsu, a.im + isu);
    out[s] = C.init(b.re + isb, b.im - rsb);
    out[s * 2] = C.init(a.re - rsu, a.im - isu);
    out[s * 3] = C.init(b.re - isb, b.im + rsb);
}
