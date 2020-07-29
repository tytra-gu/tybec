// This is a generated file. Use and modify at your own risk.
////////////////////////////////////////////////////////////////////////////////

/*******************************************************************************
Vendor: Xilinx
Associated Filename: main.c
#Purpose: This example shows a basic vector add +1 (constant) by manipulating
#         memory inplace.
*******************************************************************************/

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
#include <sys/time.h>
#include <CL/opencl.h>
#include <CL/cl_ext.h>

////////////////////////////////////////////////////////////////////////////////

#define NUM_WORKGROUPS (1)
#define WORKGROUP_SIZE (256)
//#define MAX_LENGTH 8192

#if defined(SDX_PLATFORM) && !defined(TARGET_DEVICE)
#define STR_VALUE(arg)      #arg
#define GET_STRING(name) STR_VALUE(name)
#define TARGET_DEVICE GET_STRING(SDX_PLATFORM)
#endif

////////////////////////////////////////////////////////////////////////////////

int load_file_to_memory(const char *filename, char **result)
{
    uint size = 0;
    FILE *f = fopen(filename, "rb");
    if (f == NULL) {
        *result = NULL;
        return -1; // -1 means file opening fail
    }
    fseek(f, 0, SEEK_END);
    size = ftell(f);
    fseek(f, 0, SEEK_SET);
    *result = (char *)malloc(size+1);
    if (size != fread(*result, sizeof(char), size, f)) {
        free(*result);
        return -2; // -2 means file reading fail
    }
    fclose(f);
    (*result)[size] = 0;
    return size;
}

//============================================================================
// Problem-specific
//============================================================================
  //#define VERBOSE
  #define TY_GVECT  1
  #define NTOT  1
  #define IMAX  32 
  #define JMAX  32
    //SDx read master/write master require 4kB aligned buffers
    // 32x32 makes this automatic:
      //32*32*4 = 4KB
      //subsequent pointers will automatically be 4KB aligned
  #define DATA_SIZE IMAX*JMAX
  #define MAX_LENGTH DATA_SIZE
  
  #define data_t float
  
  #define NINPUTS   4
  #define NOUTPUTS  NINPUTS 
    //this template can only same number of outputs as inputs 
    //(to make coalesced IO the same width, as they use the same interface)
    
  
//============================================================================
int main(int argc, char** argv)
//============================================================================
{
  //note: size = DATA_SIZE = MAX_LENGTH = IM*JM
    //MAX_SIZE could be different?
  
  const int imax = IMAX;
  const int jmax = JMAX; 
  const int ntot = NTOT; //total number of time interation steps
//-----------------------------------------------------------------------------------
// INIT DATA (Host and Device)
// ----------------------------------------------------------------------------------


  int size = DATA_SIZE;
  //host arrays for host run
  data_t u[imax][jmax],v[imax][jmax],un[imax][jmax],vn[imax][jmax],x[imax][jmax],y[imax][jmax],xn[imax][jmax],yn[imax][jmax];  

  //host memory for device run
  data_t h_axi00_ptr0_input [MAX_LENGTH * NINPUTS]  ; //coalesced host memory for input vector
  data_t h_axi00_ptr0_output[MAX_LENGTH * NOUTPUTS] ; //coalesced host memory for output vector

   
  for (int i = 0; i < imax; i++) {
    for (int j = 0; j < jmax; j++) {
      u[i][j] = (data_t) 3.14+(j+i*jmax)+1;
      v[i][j] = (data_t) 3.14+(j+i*jmax)+1;
      x[i][j] = (data_t) 3.14+(j+i*jmax)+1;
      y[i][j] = (data_t) 3.14+(j+i*jmax)+1;
      
      //interleave inputs into a single array for device
      h_axi00_ptr0_input  [(j+i*jmax)*NINPUTS  + 0]  = (data_t) u[i][j]; //y
      h_axi00_ptr0_input  [(j+i*jmax)*NINPUTS  + 1]  = (data_t) v[i][j]; //v
      h_axi00_ptr0_input  [(j+i*jmax)*NINPUTS  + 2]  = (data_t) x[i][j]; //u
      h_axi00_ptr0_input  [(j+i*jmax)*NINPUTS  + 3]  = (data_t) y[i][j]; //x
      h_axi00_ptr0_output [(j+i*jmax)*NOUTPUTS + 0]  = (data_t) 0; //yn
      h_axi00_ptr0_output [(j+i*jmax)*NOUTPUTS + 1]  = (data_t) 0; //un
      h_axi00_ptr0_output [(j+i*jmax)*NOUTPUTS + 2]  = (data_t) 0; //vn     
      h_axi00_ptr0_output [(j+i*jmax)*NOUTPUTS + 3]  = (data_t) 0; //xn   
   }
  }
  
//-----------------------------------------------------------------------------------
// HOST RUN (Golden results)
// ----------------------------------------------------------------------------------
  
  // Coriolis specific constants //
  //global constants
  float dt,freq,f,pi,alpha,beta;
  pi    = 4.0*atan(1.0)       ;// this calculates Pi  
  freq  = -2.*pi/(24.*3600.)  ;//
  f     = 2*freq              ;// Coriolis parameter
  dt    = 24.*3600./200.      ;// time step
  
  // parameters for semi-implicit scheme
  alpha = f*dt            ;//
  beta = 0.25*alpha*alpha ;//

  //print constant values for use in TIR/HDL
  printf("alpha = %f\n" , alpha);
  printf("beta = %f\n"  , beta);
  printf("dt = %f\n"    , dt);
  //\Coriolis specific constants //
   
  printf("TY:Starting Host run timer\n");
  
  //<----------TIMER START
  //!**** start of iteration loop ****
  for (int n =0; n < ntot; n++) {
  //!*********************************
    //time = n*dt;
    //space loop
    for (int i = 0; i < imax; i++) {
      for (int j = 0; j < jmax; j++) {
        //! velocity predictor
        //if (mode == 1) {
          un[i][j] = (u[i][j]*(1-beta)+alpha*v[i][j])/(1+beta);
          vn[i][j] = (v[i][j]*(1-beta)-alpha*u[i][j])/(1+beta);
        //}
        //else {
        //  un[i][j] = cos(alpha)*u[i][j]+sin(alpha)*v[i][j];
        //  vn[i][j] = cos(alpha)*v[i][j]-sin(alpha)*u[i][j];
        //}
        
        //! predictor of new location
        xn[i][j] = x[i][j] + dt*un[i][j]/1000;
        yn[i][j] = y[i][j] + dt*vn[i][j]/1000;
        
        //! updates for next time step 
        u[i][j] = un[i][j];
        v[i][j] = vn[i][j];
        x[i][j] = xn[i][j];
        y[i][j] = yn[i][j];
        
        //! data output
        //printf ("x[%d][%d] = %f, y[%d][%d] = %f, time = %f\n",i,j,x[i][j],i,j,y[i][j],time);
        //fprintf (fp, "x[%d][%d] = %f, y[%d][%d] = %f, time = %f\n",i,j,x[i][j],i,j,y[i][j],time);
      }//for j         
    }//for i    
  }//for n 
  //<----------TIMER END   
    
//-----------------------------------------------------------------------------------
// DEV RUN 
// ----------------------------------------------------------------------------------
    int err;                            // error code returned from api calls
    int check_status = 0;
    const uint number_of_words = DATA_SIZE; // 


    cl_platform_id platform_id;         // platform id
    cl_device_id device_id;             // compute device id
    cl_context context;                 // compute context
    cl_command_queue commands;          // compute command queue
    cl_program program;                 // compute programs
    cl_kernel kernel;                   // compute kernel

    char cl_platform_vendor[1001];
    char target_device_name[1001] = TARGET_DEVICE;

    cl_mem d_axi00_ptr0_input;  // device memory used for a vector (coalesced) input
    cl_mem d_axi00_ptr0_output; // device memory used for a vector (coalesced) output

    if (argc != 2) {
        printf("Usage: %s xclbin\n", argv[0]);
        return EXIT_FAILURE;
    }

   // Get all platforms and then select Xilinx platform
    cl_platform_id platforms[16];       // platform id
    cl_uint platform_count;
    int platform_found = 0;
    err = clGetPlatformIDs(16, platforms, &platform_count);
    if (err != CL_SUCCESS) {
        printf("Error: Failed to find an OpenCL platform!\n");
        printf("Test failed\n");
        return EXIT_FAILURE;
    }
    printf("INFO: Found %d platforms\n", platform_count);

    // Find Xilinx Plaftorm
    for (unsigned int iplat=0; iplat<platform_count; iplat++) {
        err = clGetPlatformInfo(platforms[iplat], CL_PLATFORM_VENDOR, 1000, (void *)cl_platform_vendor,NULL);
        if (err != CL_SUCCESS) {
            printf("Error: clGetPlatformInfo(CL_PLATFORM_VENDOR) failed!\n");
            printf("Test failed\n");
            return EXIT_FAILURE;
        }
        if (strcmp(cl_platform_vendor, "Xilinx") == 0) {
            printf("INFO: Selected platform %d from %s\n", iplat, cl_platform_vendor);
            platform_id = platforms[iplat];
            platform_found = 1;
        }
    }
    if (!platform_found) {
        printf("ERROR: Platform Xilinx not found. Exit.\n");
        return EXIT_FAILURE;
    }

   // Get Accelerator compute device
    cl_uint num_devices;
    unsigned int device_found = 0;
    cl_device_id devices[16];  // compute device id
    char cl_device_name[1001];
    err = clGetDeviceIDs(platform_id, CL_DEVICE_TYPE_ACCELERATOR, 16, devices, &num_devices);
    printf("INFO: Found %d devices\n", num_devices);
    if (err != CL_SUCCESS) {
        printf("ERROR: Failed to create a device group!\n");
        printf("ERROR: Test failed\n");
        return -1;
    }

    //iterate all devices to select the target device.
    for (uint i=0; i<num_devices; i++) {
        err = clGetDeviceInfo(devices[i], CL_DEVICE_NAME, 1024, cl_device_name, 0);
        if (err != CL_SUCCESS) {
            printf("Error: Failed to get device name for device %d!\n", i);
            printf("Test failed\n");
            return EXIT_FAILURE;
        }
        printf("CL_DEVICE_NAME %s\n", cl_device_name);
        if(strcmp(cl_device_name, target_device_name) == 0) {
            device_id = devices[i];
            device_found = 1;
            printf("Selected %s as the target device\n", cl_device_name);
       }
    }

    if (!device_found) {
        printf("Target device %s not found. Exit.\n", target_device_name);
        return EXIT_FAILURE;
    }

    // Create a compute context
    //
    context = clCreateContext(0, 1, &device_id, NULL, NULL, &err);
    if (!context) {
        printf("Error: Failed to create a compute context!\n");
        printf("Test failed\n");
        return EXIT_FAILURE;
    }

    // Create a command commands
    commands = clCreateCommandQueue(context, device_id, 0, &err);
    if (!commands) {
        printf("Error: Failed to create a command commands!\n");
        printf("Error: code %i\n",err);
        printf("Test failed\n");
        return EXIT_FAILURE;
    }

    int status;

    // Create Program Objects
    // Load binary from disk
    unsigned char *kernelbinary;
    char *xclbin = argv[1];

    //------------------------------------------------------------------------------
    // xclbin
    //------------------------------------------------------------------------------
    printf("INFO: loading xclbin %s\n", xclbin);
    int n_i0 = load_file_to_memory(xclbin, (char **) &kernelbinary);
    if (n_i0 < 0) {
        printf("failed to load kernel from xclbin: %s\n", xclbin);
        printf("Test failed\n");
        return EXIT_FAILURE;
    }

    size_t n0 = n_i0;

    // Create the compute program from offline
    program = clCreateProgramWithBinary(context, 1, &device_id, &n0,
                                        (const unsigned char **) &kernelbinary, &status, &err);

    if ((!program) || (err!=CL_SUCCESS)) {
        printf("Error: Failed to create compute program from binary %d!\n", err);
        printf("Test failed\n");
        return EXIT_FAILURE;
    }

    // Build the program executable
    //
    err = clBuildProgram(program, 0, NULL, NULL, NULL, NULL);
    if (err != CL_SUCCESS) {
        size_t len;
        char buffer[2048];

        printf("Error: Failed to build program executable!\n");
        clGetProgramBuildInfo(program, device_id, CL_PROGRAM_BUILD_LOG, sizeof(buffer), buffer, &len);
        printf("%s\n", buffer);
        printf("Test failed\n");
        return EXIT_FAILURE;
    }

    // Create the compute kernel in the program we wish to run
    //
     kernel = clCreateKernel(program, "krnl_vadd_rtl", &err);
    if (!kernel || err != CL_SUCCESS) {
        printf("Error: Failed to create compute kernel!\n");
        printf("Test failed\n");
        return EXIT_FAILURE;
    }

    // Create structs to define memory bank mapping
    cl_mem_ext_ptr_t d_bank_ext[4];

    d_bank_ext[0].flags = XCL_MEM_DDR_BANK0;
    d_bank_ext[0].obj = NULL;
    d_bank_ext[0].param = 0;

    d_bank_ext[1].flags = XCL_MEM_DDR_BANK1;
    d_bank_ext[1].obj = NULL;
    d_bank_ext[1].param = 0;

    d_bank_ext[2].flags = XCL_MEM_DDR_BANK2;
    d_bank_ext[2].obj = NULL;
    d_bank_ext[2].param = 0;

    d_bank_ext[3].flags = XCL_MEM_DDR_BANK3;
    d_bank_ext[3].obj = NULL;
    d_bank_ext[3].param = 0;
    // Create the input and output arrays in device memory for our calculation



    d_axi00_ptr0_input  = clCreateBuffer(context,  CL_MEM_READ_WRITE | CL_MEM_EXT_PTR_XILINX,  sizeof(data_t) * number_of_words*NINPUTS, &d_bank_ext[0], NULL);
    d_axi00_ptr0_output = clCreateBuffer(context,  CL_MEM_READ_WRITE | CL_MEM_EXT_PTR_XILINX,  sizeof(data_t) * number_of_words*NOUTPUTS, &d_bank_ext[0], NULL);


    if (!(d_axi00_ptr0_input) || !(d_axi00_ptr0_output)) {
        printf("Error: Failed to allocate device memory!\n");
        printf("Test failed\n");
        return EXIT_FAILURE;
    }
    // Write our data set into the input array in device memory
    //


    err = clEnqueueWriteBuffer(commands, d_axi00_ptr0_input, CL_TRUE, 0, sizeof(int) * number_of_words * NINPUTS, h_axi00_ptr0_input, 0, NULL, NULL);
    if (err != CL_SUCCESS) {
        printf("Error: Failed to write to source array h_axi00_ptr0_input!\n");
        printf("Test failed\n");
        return EXIT_FAILURE;
    }


    // Set the arguments to our compute kernel
    // int vector_length = MAX_LENGTH;
    err = 0;
    err |= clSetKernelArg(kernel, 0, sizeof(cl_mem), &d_axi00_ptr0_input); 
    err |= clSetKernelArg(kernel, 1, sizeof(cl_mem), &d_axi00_ptr0_output);

    if (err != CL_SUCCESS) {
        printf("Error: Failed to set kernel arguments! %d\n", err);
        printf("Test failed\n");
        return EXIT_FAILURE;
    }

    // Execute the kernel over the entire range of our 1d input data set
    // using the maximum number of work group items for this device

    err = clEnqueueTask(commands, kernel, 0, NULL, NULL);
    if (err) {
            printf("Error: Failed to execute kernel! %d\n", err);
            printf("Test failed\n");
            return EXIT_FAILURE;
        }

    // Read back the results from the device to verify the output
    //
    cl_event readevent;
    clFinish(commands);

    err = 0;
    err |= clEnqueueReadBuffer( commands, d_axi00_ptr0_output, CL_TRUE, 0, sizeof(int) * number_of_words * NOUTPUTS, h_axi00_ptr0_output, 0, NULL, &readevent );


    if (err != CL_SUCCESS) {
            printf("Error: Failed to read output array! %d\n", err);
            printf("Test failed\n");
            return EXIT_FAILURE;
        }
    clWaitForEvents(1, &readevent);
    // Check Results
    
    //const int how_many_words_to_compare = number_of_words; //mak
    const int how_many_words_to_compare = 64; //for quick verification and less clutter, check few initial results
    for (uint i = 0; i < how_many_words_to_compare; i++) {
      int r = i/jmax;
      int c = i%jmax;
      
      if (h_axi00_ptr0_output[i*NOUTPUTS+0] != yn[r][c]) { //if testing output #0
      //if (h_axi00_ptr0_output[i*NOUTPUTS+1] != un[r][c]) { //if testing output #1
      //if (h_axi00_ptr0_output[i*NOUTPUTS+2] != vn[r][c]) { //if testing output #2
      //if (h_axi00_ptr0_output[i*NOUTPUTS+3] != xn[r][c]) { //if testing output #3
        printf("ERROR,i=%d:: yn(e,a)=%f,%f; un(e,a)=%f,%f; vn(e,a)=%f,%f, xn(e,a)=%f,%f\n", i
              , yn[r][c], h_axi00_ptr0_output[i*NOUTPUTS+0]
              , un[r][c], h_axi00_ptr0_output[i*NOUTPUTS+1]
              , vn[r][c], h_axi00_ptr0_output[i*NOUTPUTS+2]
              , xn[r][c], h_axi00_ptr0_output[i*NOUTPUTS+3]
              );
          check_status = 1;
      }
      //  printf("i=%d, input=%d, output=%d\n", i,  h_axi00_ptr0_input[i], h_axi00_ptr0_output[i]);
    }


    //--------------------------------------------------------------------------
    // Shutdown and cleanup
    //-------------------------------------------------------------------------- 
    clReleaseMemObject(d_axi00_ptr0_input);
    clReleaseMemObject(d_axi00_ptr0_output);


    clReleaseProgram(program);
    clReleaseKernel(kernel);
    clReleaseCommandQueue(commands);
    clReleaseContext(context);

    if (check_status) {
        printf("INFO: Test failed\n");
        return EXIT_FAILURE;
    } else {
        printf("INFO: Test completed successfully.\n");
        return EXIT_SUCCESS;
    }


} // end of main
