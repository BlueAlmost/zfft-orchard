const std = @import("std");
const Allocator = std.mem.Allocator;
const Complex = std.math.Complex;
const print = std.debug.print;
const bufPrint = std.fmt.bufPrint;

const ValueType = @import("type_helpers").ValueType;
const ElementType = @import("type_helpers").ElementType;

const reference_fft = @import("FFT").Reference.fft;

const Config = @import("Config");

pub fn Bench() type {
    return struct {
        const Self = @This();

        m: @TypeOf(Config.m),
        n_rep: usize,
        n_loop: usize,
        sleep_ns: usize,

        fft_name: []u8,
        min_time_f32: [Config.m.len]f64,
        med_time_f32: [Config.m.len]f64,

        min_time_f64: [Config.m.len]f64,
        med_time_f64: [Config.m.len]f64,

        pub fn init() Self {
            return Self{
                .m = Config.m,
                .n_rep = Config.n_rep,
                .n_loop = Config.n_loop,
                .sleep_ns = Config.sleep_ns,

                .fft_name = undefined,
                .min_time_f32 = undefined,
                .med_time_f32 = undefined,
                .min_time_f64 = undefined,
                .med_time_f64 = undefined,
            };
        }

        pub fn gen_data(self: Self, x_ref: anytype, x: anytype) void {
            _ = self;

            const T = @TypeOf(x);
            const V = ValueType(T);

            var rnd = std.rand.DefaultPrng.init(42);
            for (x_ref, 0..) |_, i| {
                x_ref[i].re = rnd.random().float(V) - 0.5;
                x_ref[i].im = rnd.random().float(V) - 0.5;

                x[i].re = x_ref[i].re;
                x[i].im = x_ref[i].im;
            }

            if (x_ref.len == 16) {
                for (x_ref, 0..) |_, i| {
                    x_ref[i].re = -2.0 * @intToFloat(V, i);
                    x_ref[i].im = @intToFloat(V, i * i);

                    x[i].re = x_ref[i].re;
                    x[i].im = x_ref[i].im;
                }
            }
        }

        pub fn verify(self: Self, comptime C: type, in_place: bool, nfft: usize, y_ref: []C, x_ref: []C, fft: anytype, args: anytype) bool {
            const V = ValueType(C);

            reference_fft(C, nfft, y_ref.ptr, x_ref.ptr, 1);

            print("\ttesting {s}: ... ", .{self.fft_name});

            @call(.auto, fft, structToTuple(args));

            var eps: V = undefined;

            switch (V) {
                f32 => {
                    eps = @intToFloat(V, nfft) * 1e-5;
                },
                f64 => {
                    eps = @intToFloat(V, nfft) * 1e-10;
                },
                else => {
                    @compileError("unexpected type");
                },
            }

            // determine if we are doing an "in-place" by which fields exist
            if (in_place) {

                // in-place fft (compare against xp)
                var i: usize = 0;
                while (i < nfft) : (i += 1) {
                    if ((y_ref[i].re - args.xp[i].re) > eps) {
                        return false;
                    }
                    if ((y_ref[i].im - args.xp[i].im) > eps) {
                        return false;
                    }
                }
                print(" passed.\n", .{});
                return true; // verification is true

            } else {
                switch (@hasField(@TypeOf(args), "yp")) {
                    true => {

                        // not an in-place fft (compare against yp)
                        var i: usize = 0;
                        while (i < nfft) : (i += 1) {
                            if (std.math.fabs((y_ref[i].re - args.yp[i].re)) > eps) {
                                return false;
                            }
                            if (std.math.fabs((y_ref[i].im - args.yp[i].im)) > eps) {
                                return false;
                            }
                        }
                        print(" passed.\n", .{});

                        return true; // verification is true
                    },

                    false => {
                        return false;
                    },
                }
            }
        }

        pub fn speedTest(self: *Self, comptime C: type, in_place: bool, i_m: usize, x_ref: []C, fft: anytype, args: anytype) !void {
            var timer = try std.time.Timer.start();
            var time: [Config.n_rep]f64 = undefined;

            print("\t{any}, m: {d:>2}", .{ ValueType(C), self.m[i_m] });
            for (time, 0..) |_, i_rep| {
                var i_loop: usize = 0;
                var start = timer.read();
                while (i_loop < self.n_loop) : (i_loop += 1) {
                    if (in_place) {
                        // copy from safety x_ref to x used in fft
                        for (x_ref, 0..) |val, i| {
                            args.xp[i] = val;
                        }
                    }

                    @call(.auto, fft, structToTuple(args));
                }

                time[i_rep] = 1e-9 * @intToFloat(f64, timer.read() - start);
                std.time.sleep(self.sleep_ns);
            }

            switch (ValueType(C)) {
                f32 => {
                    self.min_time_f32[i_m] = minimum(&time);
                    self.med_time_f32[i_m] = median(&time);
                    print("\t{e:9.2}\n", .{self.min_time_f32[i_m]});
                },
                f64 => {
                    self.min_time_f64[i_m] = minimum(&time);
                    self.med_time_f64[i_m] = median(&time);
                    print("\t{e:9.2}\n", .{self.min_time_f64[i_m]});
                },
                else => {
                    @compileError("unexpected type");
                },
            }
        }

        fn minimum(t: []f64) f64 {
            var tmin: f64 = std.math.floatMax(f64);

            for (t) |tval| {
                if (tval < tmin) {
                    tmin = tval;
                }
            }
            return tmin;
        }

        fn cmpByValue(context: void, a: f64, b: f64) bool {
            return std.sort.asc(f64)(context, a, b);
        }

        fn median(t: []f64) f64 {
            std.sort.insertion(f64, t, {}, cmpByValue);

            if (@mod(t.len, 2) == 0) {
                var n: usize = t.len / 2;
                return 0.5 * (t[n] + t[n - 1]);
            } else {
                return t[(t.len - 1) / 2];
            }
        }

        // -----------------------------------------------------------------------
        // -----------------------------------------------------------------------
        // The original functions StructToTuple & structToTuple were posted by
        // QuantumDeveloper on zig-help discord server 15/01/2023.
        //
        // The versions here are only slightly modified to run on latest master.
        //
        pub fn StructToTuple(comptime Struct: type) type {
            var typeInfo = @typeInfo(Struct);

            const oldFields = typeInfo.Struct.fields;

            var newFields: [oldFields.len]std.builtin.Type.StructField = undefined;
            typeInfo.Struct.is_tuple = true;

            inline for (typeInfo.Struct.fields, 0..) |field, i| {
                newFields[i] = field;
                newFields[i].name = std.fmt.comptimePrint("{d}", .{i});
            }
            typeInfo.Struct.fields = &newFields;
            return @Type(typeInfo);
        }

        pub fn structToTuple(my_struct: anytype) StructToTuple(@TypeOf(my_struct)) {
            var tuple: StructToTuple(@TypeOf(my_struct)) = undefined;

            inline for (@typeInfo(@TypeOf(my_struct)).Struct.fields, 0..) |field, i| {
                tuple[i] = @field(my_struct, field.name);
            }
            return tuple;
        }

        // -----------------------------------------------------------------------
        // -----------------------------------------------------------------------

        pub fn setName(self: *Self, allocator: Allocator, SRC: anytype) !void {
            var i_dot: usize = undefined;
            var i_slash: usize = undefined;
            var i_src: usize = SRC.file.len - 1;

            while (i_src > 0) : (i_src -= 1) {
                if (SRC.file[i_src] == '.') {
                    i_dot = i_src;
                    break;
                }
            }
            while (i_src > 0) : (i_src -= 1) {
                if ((SRC.file[i_src] == '/') or (SRC.file[i_src] == '\\')) {
                    i_slash = i_src;
                    break;
                }
            }

            self.fft_name = try allocator.alloc(u8, 256);
            std.mem.copy(u8, self.fft_name, SRC.file[i_slash + 1 .. i_dot]);
            self.fft_name.len = i_dot - i_slash - 1;
        }

        pub fn writeResult(self: *Self, allocator: Allocator) !void {
            var prefix = "./results/";
            var suffix = ".json";
            var outfile = try allocator.alloc(u8, 256);

            for (prefix[0..prefix.len], 0..) |b, i| outfile[i] = b;
            for (self.fft_name[0..self.fft_name.len], 0..) |b, i| outfile[i + prefix.len] = b;
            for (suffix[0..suffix.len], 0..) |b, i| outfile[i + prefix.len + self.fft_name.len] = b;

            outfile.len = prefix.len + self.fft_name.len + suffix.len;

            try writeJson(Self, allocator, outfile, self);
        }

        // write structure to a json file
        fn writeJson(comptime T: type, allocator: Allocator, outfilename: []const u8, mystruct: *T) !void {
            var tmpstring = std.ArrayList(u8).init(allocator);
            try std.json.stringify(mystruct.*, .{}, tmpstring.writer());

            var outfile = std.fs.cwd().createFile(outfilename, .{ .read = true }) catch |err| {
                std.log.err("Could not open file: {s}, {any}.\n", .{ outfilename, err });
                return (err);
            };
            defer outfile.close();
            try outfile.writeAll(tmpstring.items);
        }
    };
}
