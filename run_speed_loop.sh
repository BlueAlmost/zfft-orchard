#!/bin/bash

# loop over the executibles built for the speed testing

for file in zig-out/bin/*;
do 
   "$file"
done

