// Before compiling this kernel, create wn_lib.aoclib with:
//    perl make_lib.pl
// Then compile this kernel with:
//    aoc -l wn_lib.aoclib -L lib1 -I lib1 example1.cl

#include "hdl_lib.h"

// Using HDL library components
kernel void cl_func_lib ( global int * restrict in1
                , global int * restrict in2
                , global int * restrict out
                , int N) {
  //If I work with single WI kernels as planned, then no need to initialize i here
  int i = get_global_id(0);
  for (int k =0; k < N; k++) {
    int a = in1[i*N + k];
    int b = in2[i*N + k];
    out[i*N + k] = func_lib(a,b);
  }
}