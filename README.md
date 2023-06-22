# zfft-orchard
zig native fft algorithms based on diaxen's fft-garden repo (originally written in c).


This zig code is based on work of Alexandre Becoulet whose c-code source
files are found at: https://github.com/diaxen/fft-garden.  

The name of this zig-code repo **"fft-orchard"** is deliberately chosen to be
similar in name as an acknowledgement to the original **"fft-garden"**.

The original fft_garden code is an initial work as part of a published
paper "A Depth-First Iterative Algorithm for the Conjugate Pair Fast Fourier
Transform" (available at: https://www.techrxiv.org/articles/preprint/A_Depth-First_Iterative_Algorithm_for_the_Conjugate_Pair_Fast_Fourier_Transform/13489392).

## Verification test
Issuing a *'zig build test'* will run verification tests on fft algorithm results, and all associated utilities.  

## Speed benchmarking test
Issuing a *'zig build'* command will build executables in the zig-out directory.  

Issuing a *'run_speed_loop.sh'* command (assumes bash shell is present on system) will loop over all fft algorithms, placing timing result json into the *results* directory.  

In the *src/julia* subdirectory there is a *plot_results.jl* program that will produce 8 plot figures of the timing resutls as below for conjugate pair float 64:
![Figure_5](https://github.com/BlueAlmost/zfft-orchard/assets/100024520/212c5d48-5980-4357-82f0-b3d0042b35e6)

## Naming of fft algorithm source files

For the fft algorithm files, the naming of the zig source files reflects the naming
of the original c-code files.  The names consist of 3 parts (and a 4th optional part):

**1.** **BUTTERFLY DESIGN:**

   **ct**  -  cooley-tukey radix-2 fft  
   **mr**  -  mixed radix 2/4 fft  
   **sr**  -  split radix fft  
   **cp**  -  conjugate pair fft  

**2.** **DECIMATION:**

   **dit**  -  decimation in time  
   **dif**  -  decimation in freq  

**3.** **TRAVERSAL & ALGORITHM STRUCTURE:**

   **bi**  -  breadth-first iterative  
   **dr**  -  depth-first recursive  
   **di**  -  depth-first iterative  

**4.** **OPTIONAL ADDITIONAL PROPERTIES:**

   **G**  -  butterflies use same twiddles grouped by stage  
   **S**  -  butterflies use same twiddels grouped by block  
   **L**  -  input reordering and/or butterfly scheduling may rely on lookup tables  
   **P**  -  butterfly functions may be simplified from some twiddle factor values  
   **F**  -  twiddle table may be reduced to N/8 entries  
   **N**  -  algorithm made to work in-place  


