# prints speed comparison plots of the variousl ffts.

using JSON
using Printf
using Glob
using PyPlot

for i=1:8
   fig = plt.figure(i)
   fig.set_size_inches(9, 5.5)
end

dataDir = "../../results/";
flist = glob( dataDir * "*.json")

global n_rep
global n_loop
global ylim_max = 0


for ifile in flist

   global ylim_max

   println(ifile)

   fstr = open(ifile, "r")
   d = JSON.parse(fstr)
   close(fstr)

   fft_name = d["fft_name"]

   m = Int64.(d["m"]);
   mark_sz = 7
   alph = 0.7

   nlogn = (2 .^ m) .* m
   global n_rep = Int64.(d["n_rep"]);
   global n_loop = Int64.(d["n_loop"]);

   min32 = Float64.(d["min_time_f32"]);
   med32 = Float64.(d["med_time_f32"]);
   min64 = Float64.(d["min_time_f64"]);
   med64 = Float64.(d["med_time_f64"]);

   max_test = maximum([maximum(min32./nlogn), maximum(min64./nlogn)])
   if (max_test > ylim_max) & (fft_name != "reference_fft")
      ylim_max = max_test
   end

   if(fft_name[1:2] == "cp")
     
      figure(1)
      plot(m, min32./nlogn, ls="-", marker="o", ms=mark_sz, alpha=alph, label=fft_name);
      title("conjugate pair - float32")

      figure(5)
      plot(m, min64./nlogn, ls="-", marker="o", ms=mark_sz, alpha=alph, label=fft_name);
      title("conjugate pair - float64")

   elseif(fft_name[1:2] == "ct")

      figure(2)
      plot(m, min32./nlogn, ls="-", marker="o", ms=mark_sz, alpha=alph, label=fft_name);
      title("cooley-tukey - float32")

      figure(6)
      plot(m, min64./nlogn, ls="-", marker="o", ms=mark_sz, alpha=alph, label=fft_name);
      title("cooley-tukey - float64")

   elseif(fft_name[1:2] == "mr")

      figure(3)
      plot(m, min32./nlogn, ls="-", marker="o", ms=mark_sz, alpha=alph, label=fft_name);
      title("mixed radix - float32")

      figure(7)
      plot(m, min64./nlogn, ls="-", marker="o", ms=mark_sz, alpha=alph, label=fft_name);
      title("mixed radix - float64")

   elseif(fft_name[1:2] == "sr")

      figure(4)
      plot(m, min32./nlogn, ls="-", marker="o", ms=mark_sz, alpha=alph, label=fft_name);
      title("split radix - float32")

      figure(8)
      plot(m, min64./nlogn, ls="-", marker="o", ms=mark_sz, alpha=alph, label=fft_name);
      title("split radix - float64")

   end

end

for i=1:8
   box_wid = 0.85
   fig = plt.figure(i)
   ax = gca();
   legend()
   box = ax.get_position()
   ax.set_position([box.x0, box.y0, box.width * box_wid, box.height])
   ax.legend(loc="upper left", bbox_to_anchor=(1.0, 1.0))
   ax.grid("on")

   ylabel("minimum time / n \$log_2(n)\$")
   ylim([0, ylim_max])
   xlabel("\$log_2(n)\$")

   note = "n_rep:  " * string(n_rep) * ",  n_loop:  " * string(n_loop)
   ax.annotate(note, xy=[0.75, -0.08], xycoords="axes fraction")
end

