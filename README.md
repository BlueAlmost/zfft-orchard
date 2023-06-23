# zfft-orchard
This repo contains zig native implementations of a large variety fft algorithms based on
Alexandre Becoulet's fft-garden c-code source files are found at: https://github.com/diaxen/fft-garden. 

The original fft-garden code is described as *'initial work'* as part of a published
paper "A Depth-First Iterative Algorithm for the Conjugate Pair Fast Fourier
Transform" (available at: https://www.techrxiv.org/articles/preprint/A_Depth-First_Iterative_Algorithm_for_the_Conjugate_Pair_Fast_Fourier_Transform/13489392).

A preprint version of this paper (released under Creative Commons Attribution-NonCommerical-ShareAlike 4.0 International License) is included in the *docs* subdirectory here.  This paper provides excellent explanation of the variety of fft variants and context for execution aspects regarding cache hits/memory accesses, etc.  

The zig versions of the fft algorithms attempt to remain as close to the original c-code as possible, while still following zig idioms.  A more liberal translation approach was taken with regard to the supporting code (butterflies, luts, etc.).

The name of this zig-code repo **"fft-orchard"** is deliberately chosen to be
similar in name as an acknowledgement to the original **"fft-garden"**.  

### Verification test
Issuing a ***'zig build test'*** will run verification tests on fft algorithm results, and all associated utilities.  

### Speed benchmarking test
Issuing a ***'zig build'*** command will build executables in the *'zig-out/bin'* directory.  

Issuing a ***'run_speed_loop.sh'*** command (assumes bash shell is present on system) will loop over all fft algorithms, placing timing results json files into the *'results'* directory.  

In the *'src/julia'* subdirectory there is a *'plot_results.jl'* program that will produce eight plot figures of the timing results. An example figure is found below for conjugate pair float 64:  
![Figure_5](https://github.com/BlueAlmost/zfft-orchard/assets/100024520/2e54c7aa-ad5b-4961-b42f-7244f055b211)


### Naming of fft algorithm source files

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

### License
MIT License

### Feedback  

Feedback is welcomed, (git.blue.almost@gmail.com).  
