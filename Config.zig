// define fft lengths of interest for verification and speed testing
// (length of fft is 2^m)
// pub const m = [_]usize { 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 };
pub const m = [_]usize{ 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14 };
// pub const m = [_]usize{ 8, 9, 10, 11};

// looping parameters for speed testing (i.e. number of ffts to be run)
pub const n_rep = 100;
pub const n_loop = 500;
pub const sleep_ns = 1000;
