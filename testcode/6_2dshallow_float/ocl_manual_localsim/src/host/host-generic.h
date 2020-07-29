#ifndef _HOST_GENERIC_H_
#define _HOST_GENERIC_H_

// ======================================================
// Generic header file for tytra het' opencl framework 
// Primary target is FPGA, but also meant to work with 
// GPUs and CPUs
// By: Syed Waqar Nabi, Glasgow
// 2016.12.05
// ======================================================

//------------------------------------------
// DATA TYPE AND PROBLEM SIZE
//------------------------------------------
//define NX and NY (2 less then the ARRAY-SIZE, ARRAY has additional values for boundry/land)
//TODO: The build script assumes DIM1=DIM2 so just working with it for now
//      But this is an artificial constraint which should be removed eventually
#define ROWS      1024
#define COLS      ROWS
#define SIZE      (ROWS*COLS)

#define NX    (ROWS-2)
#define NY    (COLS-2)
#define XMID  (NX/2)
#define YMID  (NY/2)

#define NTOT      1
#define NTIMES    1
#define NPROGRAMS 1

#define data_t int

// =========================
// Generic inludes
// =========================
// include common file used for enumerations in both host and device

#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <unistd.h>
#include <assert.h>
#include <stdbool.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <float.h>

//TODO: remove c++ dependancy
#include <cstdlib>
#include <iostream>
#include <iomanip>
#include <cstring>
#include <cassert>
//
#include <fstream>
#include <vector>
#include <cmath>

//#include <cfloat>

#include <chrono>

// =========================
// OpenCL
// =========================
#include <CL/opencl.h>

#define SDACCEL_ALIGNMENT 64
#define ALIGNMENT         SDACCEL_ALIGNMENT

// =========================
// Commonly used Macros
// =========================
# define HLINE "-------------------------------------------------------------\n"
# define SLINE "*************************************************************\n"

# ifndef MIN
# define MIN(x,y) ((x)<(y)?(x):(y))
# endif
# ifndef MAX
# define MAX(x,y) ((x)>(y)?(x):(y))
# endif

// =====================================
// Application 
// =====================================

// -------------------------------------
// Default Benchmark Paramters
// -------------------------------------

// We *must* ensure that we protect any 
// previous definitin of macros, which should
// supercede the following defaults

//#define USECHANNELS

//#define EPSILON 0.00001
//#define EPSILON 0.0001
#define EPSILON 0.1
//#define EPSILON 0.1
//Is this too random? [used for comparing floats]
  

// -------------------------------------
// KERNELS
// -------------------------------------
//#ifdef SINGLEWI_KERNEL
//  #ifdef USECHANNELS
//    #define NKERNELS 9
//    #define K_MEM_RD  				      0
//    #define K_SMACHE_MEMRD_2_DYN1	  1
//    #define K_DYN1    				      2
//    #define K_SMACHE_DYN1_2_DYN2	  3
//    #define K_DYN2    				      4
//    #define K_SMACHE_DYN2_2_SHAPIRO	5
//    #define K_SHAPIRO 				      6
//    #define K_UPDATES 				      7
//    #define K_MEM_WR  				      8
//  #else  
    #define NKERNELS 1
//  #endif
//#endif  

//#ifdef NDRANGE_KERNEL
//  #define NKERNELS  4
//  #define K_DYN1    0
//  #define K_DYN2    1
//  #define K_SHAPIRO 2
//  #define K_UPDATES 3
//#endif  

//choice of kernel



//-------------------------------
// CHECK_ERRORS()
//-------------------------------
#define CHECK_ERRORS(ERR, STRING)           \
    if(ERR != CL_SUCCESS)                   \
    {                                       \
      printf("OpenCL error with code %d ::  \
        happened in file %s ::              \
        at line %d ::                       \
        Error Message from Program %s ::    \
        Exiting...\n",                      \
      ERR, __FILE__, __LINE__, STRING);     \
      exit(1);                              \
    }


//-------------------------------
// OCLBASIC_PRINT_TEXT_PROPERTY()
//-------------------------------
#define OCLBASIC_PRINT_TEXT_PROPERTY(NAME) {           \
  /* When we query for string properties, first we */  \
  /* need to get string length:                    */  \
  size_t property_length = 0;                          \
  err = clGetDeviceInfo(                               \
    device_id,                                         \
    NAME,                                              \
    0,                                                 \
    0,                                                 \
    &property_length                                   \
    );                                                 \
  CHECK_ERRORS(err,"");                                \
  /* Then allocate buffer. No need to add 1 symbol */  \
  /* to store terminating zero; OpenCL takes care  */  \
  /* about it:                                     */  \
  char* property_value = new char[property_length];    \
  err = clGetDeviceInfo(                               \
    device_id,                                         \
    NAME,                                              \
    property_length,                                   \
    property_value,                                    \
    0                                                  \
  );                                                   \
  CHECK_ERRORS(err,"");                                \
  printf("%s:\t%s\n", #NAME, property_value );         \
  delete [] property_value;                            \
  } 


#define OCLBASIC_PRINT_NUMERIC_PROPERTY(NAME, TYPE) {  \
  TYPE property_value;                                 \
  size_t property_length = 0;                          \
  err = clGetDeviceInfo(                               \
    device_id,                                         \
    NAME,                                              \
    sizeof(property_value),                            \
    &property_value,                                   \
    &property_length                                   \
  );                                                   \
  assert(property_length == sizeof(property_value));   \
  CHECK_ERRORS(err,"");                                \
  printf("%s:\t%d\n", #NAME, property_value);          \
 }

//----------------------------------------------------
// load_file_to_memory()
//----------------------------------------------------
int load_file_to_memory(const char *filename, char **result);

//----------------------------------------------------
// oclh_init_data()
//----------------------------------------------------
void oclh_init_data(data_t* a2d, data_t* b2d, data_t* c2d, int BytesPerWord);

//----------------------------------------------------
// display setup()
//----------------------------------------------------
void oclh_display_setup();



//----------------------------------------------------
// oclh_opencl_boilerplate()
//----------------------------------------------------
int  oclh_opencl_boilerplate ( cl_context*      context_ref
                            , cl_command_queue* commands_ref
                            , cl_program*       program_ref
                            , cl_kernel*        kernel_ref
                            , int               argc
                            , char**            argv
) ;//oclh_opencl_boilerplate

//----------------------------------------------------
// oclh_create_device_buffer()
//----------------------------------------------------
void oclh_create_cldevice_buffer ( cl_mem*     buffer
                                 , cl_context* context
                                 , cl_mem_flags flag
) ;

//----------------------------------------------------
// oclh_blocking_write_cl_buffer()
//----------------------------------------------------
void oclh_blocking_write_cl_buffer ( cl_command_queue* commands
                                  , cl_mem*           dbuffer
                                  , data_t*        hbuffer
) ;

//----------------------------------------------------
// oclh_blocking_read_cl_buffer()
//----------------------------------------------------
void oclh_blocking_read_cl_buffer ( cl_command_queue* commands
                                  , cl_mem*           dbuffer
                                  , data_t*        hbuffer
) ;

//----------------------------------------------------
// oclh_set_kernel_args()
//----------------------------------------------------
void oclh_set_kernel_args ( cl_kernel* kernels 
                          , data_t* dt
                          , data_t* dx
                          , data_t* dy
                          , data_t* g
                          , data_t* eps
                          , data_t* hmin
                          , cl_mem*    dev_eta
                          , cl_mem*    dev_un
                          , cl_mem*    dev_u
                          , cl_mem*    dev_wet
                          , cl_mem*    dev_v
                          , cl_mem*    dev_vn
                          , cl_mem*    dev_h
                          , cl_mem*    dev_etan
                          , cl_mem*    dev_hzero
//                          , int*       rows
//                          , int*       cols
                          );
//----------------------------------------------------
// oclh_get_global_local_sizes()
//----------------------------------------------------
void oclh_get_global_local_sizes ( size_t* globalSize
                                , size_t* localSize
);

//----------------------------------------------------
// oclh_get_global_local_sizes()
//----------------------------------------------------
void oclh_enq_cl_kernel  ( cl_command_queue* commands
                        , cl_kernel*        kernel
                        , size_t*           globalSize
                        , size_t*           localSize
) ;

//----------------------------------------------------
// oclh_log_results
//----------------------------------------------------
void oclh_log_results  ( data_t* eta
                      , data_t*  h
                      , data_t*  h_g
                      , data_t*  u
                      , data_t*  v
                      , data_t*  h0
);

//----------------------------------------------------
// oclh_verify_results()
//----------------------------------------------------
int oclh_verify_results ( data_t* h
                        , data_t* h_g
);

//----------------------------------------------------
// oclh_calculate_bandwidth()
//----------------------------------------------------
void oclh_calculate_performance(
);

//----------------------------------------------------
// oclh_disp_timing_profile()
//----------------------------------------------------
void oclh_disp_timing_profile();

#endif
