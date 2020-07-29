// Before compiling this kernel, create wn_lib.aoclib with:
//    perl make_lib.pl
// Then compile this kernel with:
//    aoc -l wn_lib.aoclib -L lib1 -I lib1 example1.cl

#include "hdl_lib.h"
typedef int device_t;
#define SIZE 16

#pragma OPENCL EXTENSION cl_altera_channels : enable

//Channels
channel device_t ch_kt_vin0_memrd_2_kernel_A;
channel device_t ch_kt_vin1_memrd_2_kernel_A;
  
channel device_t ch_vconn_A_to_B;
channel device_t ch_vconn_B_to_C;
channel device_t ch_vconn_C_to_D;

channel device_t ch_kernel_D_to_kt_vout_memwr;
// ===============================
// KERNELS
// ===============================

//------------------------------------------
// Read memory kernel
//------------------------------------------
__kernel void kernel_mem_rd( __global device_t * restrict kt_vin0
                           , __global device_t * restrict kt_vin1
                      ) { 
  uint j, k, index;
  for (index=0; index < SIZE; index++) {     
      device_t kt_vin0_data = kt_vin0[index];
      device_t kt_vin1_data = kt_vin1[index];
      
      write_channel_altera(ch_kt_vin0_memrd_2_kernel_A ,kt_vin0_data   ); mem_fence(CLK_CHANNEL_MEM_FENCE);
      write_channel_altera(ch_kt_vin1_memrd_2_kernel_A ,kt_vin1_data   );    
  }
}


//------------------------------------------
// Kernel_A
//------------------------------------------
kernel void cl_func_lib_kernel_A () {
  device_t kt_vin0;
  device_t kt_vin1;
  device_t vconn_A_to_B;
  // The main loop //
  for (int count=0; count < SIZE; count++) {  
    kt_vin0 = read_channel_altera (ch_kt_vin0_memrd_2_kernel_A); mem_fence(CLK_CHANNEL_MEM_FENCE);
    kt_vin1 = read_channel_altera (ch_kt_vin1_memrd_2_kernel_A); 
    
    vconn_A_to_B = func_lib_kernel_A(kt_vin0,kt_vin0);
    
    write_channel_altera(ch_vconn_A_to_B   , vconn_A_to_B);   
  }
}

//------------------------------------------
// Kernel_B
//------------------------------------------
kernel void cl_func_lib_kernel_B () {
  device_t vconn_A_to_B;
  device_t vconn_B_to_C;
  // The main loop //
  for (int count=0; count < SIZE; count++) {  
    vconn_A_to_B = read_channel_altera (ch_vconn_A_to_B);
    
    vconn_B_to_C = func_lib_kernel_B(vconn_A_to_B);
    
    write_channel_altera(ch_vconn_B_to_C   , vconn_B_to_C);   
  }
}

//------------------------------------------
// Kernel_C
//------------------------------------------
kernel void cl_func_lib_kernel_C () {
  device_t vconn_B_to_C;
  device_t vconn_C_to_D;
  // The main loop //
  for (int count=0; count < SIZE; count++) {  
    vconn_B_to_C = read_channel_altera (ch_vconn_B_to_C);
    
    vconn_C_to_D = func_lib_kernel_C(vconn_B_to_C);
    
    write_channel_altera(ch_vconn_C_to_D   , vconn_C_to_D);   
  }
}

//------------------------------------------
// Kernel_D
//------------------------------------------
kernel void cl_func_lib_kernel_D () {
  device_t vconn_C_to_D;
  device_t kt_vout;
  // The main loop //
  for (int count=0; count < SIZE; count++) {  
    vconn_C_to_D = read_channel_altera (ch_vconn_C_to_D);
    
    kt_vout = func_lib_kernel_D(vconn_C_to_D);
    
    write_channel_altera(ch_kernel_D_to_kt_vout_memwr   , kt_vout);   
  }
}

//------------------------------------------
// Write memory kernel
//------------------------------------------
kernel void kernel_mem_wr  (__global device_t* kt_vout
) {
  for (int index=0; index < SIZE; index++) {       
      device_t kt_vout_data   = read_channel_altera(ch_kernel_D_to_kt_vout_memwr);
      
      kt_vout[index] = kt_vout_data;
  }
}//()