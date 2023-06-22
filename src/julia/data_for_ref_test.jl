# this generates is simple 8 point fft input/output to be used for
# the zig reference fft implementation.

using FFTW;

n = 8;

r = zeros(n)
i = zeros(n)

r[0+1] =  1.1;
r[1+1] = -2.5;
r[2+1] =  1.4;
r[3+1] =  2.3;
r[4+1] = -1.1;
r[5+1] = -2.2;
r[6+1] =  2.2;
r[7+1] =  1.2;

i[0+1] = -0.1;
i[1+1] = -2.1;
i[2+1] =  1.4;
i[3+1] =  0.2;
i[4+1] =  1.1;
i[5+1] = -2.2;
i[6+1] = -0.2;
i[7+1] = -1.4;

x = r + im*i;

X = fft(x)

