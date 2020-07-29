// =============================================================================
// Company              : Unversity of Glasgow, Comuting Science
// Template Author      : S Waqar Nabi
// Template origin date : 2019.07.29
//
// Project Name         : TyTra
//
// Target Devices       : Xilinx Ultrascale (AWS)
//
// Generated Design Name: untitled
// Generated Module Name: main.c
// Generator Version    : R17.0
// Generator TimeStamp  : Tue Nov 26 16:30:57 2019
// 
// Dependencies         : <dependencies>
//
// =============================================================================
// General Description
// -----------------------------------------------------------------------------
//  *******************************************************************************/

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
#include <time.h>
#include <chrono>

////////////////////////////////////////////////////////////////////////////////
#define NUM_WORKGROUPS (1)
#define WORKGROUP_SIZE (256)
//#define MAX_LENGTH 8192

#if defined(SDX_PLATFORM) && !defined(TARGET_DEVICE)
#define STR_VALUE(arg)      #arg
#define GET_STRING(name) STR_VALUE(name)
#define TARGET_DEVICE GET_STRING(SDX_PLATFORM)
#endif

//============================================================================
// Problem-specific
//============================================================================
  //#define VERBOSE
  #define TY_GVECT    1 
    //ocl-only code not compatibel with vectorization, so this must be 1
  #define NTOT        1
  #define DATA_SIZE   1024*1024
    //SDx read master/write master require 4kB aligned buffers
    // e.g. 1024 (or 32x32 for 2D square grid) makes this automatic:
      //32*32*4 = 4KB
      //subsequent pointers will automatically be 4KB aligned
  
  #define data_t float
    #define NINPUTS   4
  #define NOUTPUTS  NINPUTS 
    //this template can only same number of outputs as inputs 
    //(to make coalesced IO the same width, as they use the same interface)    

////////////////////////////////////////////////////////////////////////////////
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
int main(int argc, char** argv)
//============================================================================
{
  const int data_size = DATA_SIZE;
  const int imax = (int)sqrt((double)data_size);
  const int jmax = (int)sqrt((double)data_size); 
  const int ntot = NTOT; //total number of time interation steps
  const int vect = TY_GVECT; 
  
  //display problem size, vectorization factor
  printf("\n-------------------------------------------\n");
  printf("Size of arrays (DATA_SIZE)      = %d\n", data_size);
  printf("Number of time steps (NTOT)     = %d\n", ntot);
  printf("Vectorization factor (TY_GVECT) = %d\n", vect);
  printf("-------------------------------------------\n");
//-----------------------------------------------------------------------------------
// INIT DATA (Host and Device)
// ----------------------------------------------------------------------------------


  int size = DATA_SIZE;
  unsigned int size_in_bytes = DATA_SIZE * sizeof(data_t);
  
  //host arrays for host run
  data_t* x = (data_t*) malloc(size_in_bytes);
  data_t* u = (data_t*) malloc(size_in_bytes);
  data_t* v = (data_t*) malloc(size_in_bytes);
  data_t* y = (data_t*) malloc(size_in_bytes);
  data_t* xn = (data_t*) malloc(size_in_bytes);
  data_t* un = (data_t*) malloc(size_in_bytes);
  data_t* vn = (data_t*) malloc(size_in_bytes);
  data_t* yn = (data_t*) malloc(size_in_bytes);


  //host memory for device run
  data_t* h_axi00_ptr0_input_x    = (data_t*) malloc(size_in_bytes); 
  data_t* h_axi00_ptr0_input_u    = (data_t*) malloc(size_in_bytes); 
  data_t* h_axi00_ptr0_input_v    = (data_t*) malloc(size_in_bytes); 
  data_t* h_axi00_ptr0_input_y    = (data_t*) malloc(size_in_bytes); 
  data_t* h_axi00_ptr0_output_xn  = (data_t*) malloc(size_in_bytes); 
  data_t* h_axi00_ptr0_output_un  = (data_t*) malloc(size_in_bytes); 
  data_t* h_axi00_ptr0_output_vn  = (data_t*) malloc(size_in_bytes); 
  data_t* h_axi00_ptr0_output_yn  = (data_t*) malloc(size_in_bytes); 

  //init data
  for (int i = 0; i < imax; i++) {
    for (int j = 0; j < jmax; j=j+vect) { //vect _must_ be a factor of jmax
      //for (int w = 0; w < vect; w++) {
      x[i*jmax + j] = (data_t) 3.14+(j+i*jmax)+1;
      u[i*jmax + j] = (data_t) 3.14+(j+i*jmax)+1;
      v[i*jmax + j] = (data_t) 3.14+(j+i*jmax)+1;
      y[i*jmax + j] = (data_t) 3.14+(j+i*jmax)+1;
      
      h_axi00_ptr0_input_x  [(j+i*jmax)]= (data_t) x[i*jmax + j];
      h_axi00_ptr0_input_u  [(j+i*jmax)]= (data_t) u[i*jmax + j];
      h_axi00_ptr0_input_v  [(j+i*jmax)]= (data_t) v[i*jmax + j];
      h_axi00_ptr0_input_y  [(j+i*jmax)]= (data_t) y[i*jmax + j];

      h_axi00_ptr0_output_xn [(j+i*jmax)]= (data_t) 0; //xn
      h_axi00_ptr0_output_un [(j+i*jmax)]= (data_t) 0; //un
      h_axi00_ptr0_output_vn [(j+i*jmax)]= (data_t) 0; //vn
      h_axi00_ptr0_output_yn [(j+i*jmax)]= (data_t) 0; //yn
      //}
    }
  }
  
//-----------------------------------------------------------------------------------
// HOST RUN (Golden results)
// ---------------------------------------------------------------------------------- 
  printf("TY: Starting Host run\n");
    float dt,freq,f,pi,alpha,beta;
  
  // Coriolis specific constants //
  //global constants
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
   
  auto cstart = std::chrono::high_resolution_clock::now();        //<----------TIMER START  
  
  //!**** start of iteration loop ****
  for (int n =0; n < ntot; n++) {
  //!*********************************
    //time = n*dt;
    //space loop
    for (int i = 0; i < imax; i++) {
      for (int j = 0; j < jmax; j++) {
        //! velocity predictor
        //if (mode == 1) {
          un[i*jmax + j] = (u[i*jmax + j]*(1-beta)+alpha*v[i*jmax + j])/(1+beta);
          vn[i*jmax + j] = (v[i*jmax + j]*(1-beta)-alpha*u[i*jmax + j])/(1+beta);
        //}
        //else {
        //  un[i][j] = cos(alpha)*u[i][j]+sin(alpha)*v[i][j];
        //  vn[i][j] = cos(alpha)*v[i][j]-sin(alpha)*u[i][j];
        //}
        
        //! predictor of new location
        xn[i*jmax + j] = x[i*jmax + j] + dt*un[i*jmax + j]/1000;
        yn[i*jmax + j] = y[i*jmax + j] + dt*vn[i*jmax + j]/1000;
        
        //! updates for next time step 
        u[i*jmax + j] = un[i*jmax + j];
        v[i*jmax + j] = vn[i*jmax + j];
        x[i*jmax + j] = xn[i*jmax + j];
        y[i*jmax + j] = yn[i*jmax + j];
      }//for j         
    }//for i    
  }//for n 
  auto cend = std::chrono::high_resolution_clock::now();          //<----------TIMER END
  std::chrono::duration<double> cpu_time_used = cend - cstart;

  printf("TY: Host run complete\n");    
  
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

    // device memory pointers
    cl_mem d_axi00_ptr0_input_x;  
    cl_mem d_axi00_ptr0_input_u;
    cl_mem d_axi00_ptr0_input_v;
    cl_mem d_axi00_ptr0_input_y;
    
    cl_mem d_axi00_ptr0_output_xn; 
    cl_mem d_axi00_ptr0_output_un; 
    cl_mem d_axi00_ptr0_output_vn; 
    cl_mem d_axi00_ptr0_output_yn; 

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
     kernel = clCreateKernel(program, "oclComputeKernel", &err);
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



    d_axi00_ptr0_input_x  = clCreateBuffer(context,  CL_MEM_READ_WRITE | CL_MEM_EXT_PTR_XILINX,  sizeof(data_t) * number_of_words, &d_bank_ext[0], NULL);
    d_axi00_ptr0_input_u  = clCreateBuffer(context,  CL_MEM_READ_WRITE | CL_MEM_EXT_PTR_XILINX,  sizeof(data_t) * number_of_words, &d_bank_ext[0], NULL);
    d_axi00_ptr0_input_v  = clCreateBuffer(context,  CL_MEM_READ_WRITE | CL_MEM_EXT_PTR_XILINX,  sizeof(data_t) * number_of_words, &d_bank_ext[0], NULL);
    d_axi00_ptr0_input_y  = clCreateBuffer(context,  CL_MEM_READ_WRITE | CL_MEM_EXT_PTR_XILINX,  sizeof(data_t) * number_of_words, &d_bank_ext[0], NULL);
    d_axi00_ptr0_output_xn= clCreateBuffer(context,  CL_MEM_READ_WRITE | CL_MEM_EXT_PTR_XILINX,  sizeof(data_t) * number_of_words, &d_bank_ext[0], NULL);
    d_axi00_ptr0_output_un= clCreateBuffer(context,  CL_MEM_READ_WRITE | CL_MEM_EXT_PTR_XILINX,  sizeof(data_t) * number_of_words, &d_bank_ext[0], NULL);
    d_axi00_ptr0_output_vn= clCreateBuffer(context,  CL_MEM_READ_WRITE | CL_MEM_EXT_PTR_XILINX,  sizeof(data_t) * number_of_words, &d_bank_ext[0], NULL);
    d_axi00_ptr0_output_yn= clCreateBuffer(context,  CL_MEM_READ_WRITE | CL_MEM_EXT_PTR_XILINX,  sizeof(data_t) * number_of_words, &d_bank_ext[0], NULL);


    if (  !(d_axi00_ptr0_input_x  ) 
      ||  !(d_axi00_ptr0_input_u  )
      ||  !(d_axi00_ptr0_input_v  )
      ||  !(d_axi00_ptr0_input_y  )
      ||  !(d_axi00_ptr0_output_xn)
      ||  !(d_axi00_ptr0_output_un)
      ||  !(d_axi00_ptr0_output_vn)
      ||  !(d_axi00_ptr0_output_yn)
    ) {
        printf("Error: Failed to allocate device memory!\n");
        printf("Test failed\n");
        return EXIT_FAILURE;
    }
    // Write our data set into the input array in device memory
    //

    err  = 0;
    err |= clEnqueueWriteBuffer(commands, d_axi00_ptr0_input_x, CL_TRUE, 0, sizeof(int) * number_of_words, h_axi00_ptr0_input_x, 0, NULL, NULL);
    err |= clEnqueueWriteBuffer(commands, d_axi00_ptr0_input_u, CL_TRUE, 0, sizeof(int) * number_of_words, h_axi00_ptr0_input_u, 0, NULL, NULL);
    err |= clEnqueueWriteBuffer(commands, d_axi00_ptr0_input_v, CL_TRUE, 0, sizeof(int) * number_of_words, h_axi00_ptr0_input_v, 0, NULL, NULL);
    err |= clEnqueueWriteBuffer(commands, d_axi00_ptr0_input_y, CL_TRUE, 0, sizeof(int) * number_of_words, h_axi00_ptr0_input_y, 0, NULL, NULL);
    
    if (err != CL_SUCCESS) {
        printf("Error: Failed to write to source array h_axi00_ptr0_input!\n");
        printf("Test failed\n");
        return EXIT_FAILURE;
    }


    // Set the arguments to our compute kernel    
    err = 0;
    err |= clSetKernelArg(kernel, 0, sizeof(cl_mem),  &d_axi00_ptr0_input_u  );
    err |= clSetKernelArg(kernel, 1, sizeof(cl_mem),  &d_axi00_ptr0_input_x  ); 
    err |= clSetKernelArg(kernel, 2, sizeof(cl_mem),  &d_axi00_ptr0_input_v  );
    err |= clSetKernelArg(kernel, 3, sizeof(cl_mem),  &d_axi00_ptr0_input_y  );
    err |= clSetKernelArg(kernel, 4, sizeof(cl_mem),  &d_axi00_ptr0_output_un);
    err |= clSetKernelArg(kernel, 5, sizeof(cl_mem),  &d_axi00_ptr0_output_xn);
    err |= clSetKernelArg(kernel, 6, sizeof(cl_mem),  &d_axi00_ptr0_output_vn);
    err |= clSetKernelArg(kernel, 7, sizeof(cl_mem),  &d_axi00_ptr0_output_yn);
    err |= clSetKernelArg(kernel, 8, sizeof(cl_uint), &size);
    
    if (err != CL_SUCCESS) {
        printf("Error: Failed to set kernel arguments! %d\n", err);
        printf("Test failed\n");
        return EXIT_FAILURE;
    }

    // -------------------------------------------------------------------
    // KERNEL EXEC
    // -------------------------------------------------------------------
    
    // Execute the kernel over the entire range of our 1d input data set
    // using the maximum number of work group items for this device
    auto dstart = std::chrono::high_resolution_clock::now();  //<----------TIMER START
    //!**** start of iteration loop ****
    for (int n =0; n < ntot; n++) {
    //!*********************************
      err = clEnqueueTask(commands, kernel, 0, NULL, NULL);
      if (err) {
              printf("Error: Failed to execute kernel! %d\n", err);
              printf("Test failed\n");
              return EXIT_FAILURE;
          }
  
      // Read back the results from the device to verify the output
      //
      clFinish(commands);
    }
    auto dend = std::chrono::high_resolution_clock::now();    //<----------TIMER START
    std::chrono::duration<double> dev_time_used = dend - dstart;

    cl_event readevent;
    err = 0;
    err |= clEnqueueReadBuffer( commands, d_axi00_ptr0_output_un, CL_TRUE, 0, sizeof(int) * number_of_words, h_axi00_ptr0_output_un, 0, NULL, &readevent );
    err |= clEnqueueReadBuffer( commands, d_axi00_ptr0_output_xn, CL_TRUE, 0, sizeof(int) * number_of_words, h_axi00_ptr0_output_xn, 0, NULL, &readevent );
    err |= clEnqueueReadBuffer( commands, d_axi00_ptr0_output_vn, CL_TRUE, 0, sizeof(int) * number_of_words, h_axi00_ptr0_output_vn, 0, NULL, &readevent );
    err |= clEnqueueReadBuffer( commands, d_axi00_ptr0_output_yn, CL_TRUE, 0, sizeof(int) * number_of_words, h_axi00_ptr0_output_yn, 0, NULL, &readevent );


    if (err != CL_SUCCESS) {
            printf("Error: Failed to read output array! %d\n", err);
            printf("Test failed\n");
            return EXIT_FAILURE;
        }
    clWaitForEvents(1, &readevent);

    //------------------------------------------------------------------------------
    // Check Results
    //------------------------------------------------------------------------------
    
    //const int how_many_words_to_compare = number_of_words; //mak
    const int how_many_words_to_compare = 16; //for quick verification and less clutter, check few initial results
    for (uint i = 0; i < how_many_words_to_compare; i=i+vect) {
      //for (uint w = 0; w < vect; w++) {
        int r = i/jmax;
        int c = i%jmax;
        
      if (
         (h_axi00_ptr0_output_xn[i]!= xn[r*jmax + c]) ||
         (h_axi00_ptr0_output_un[i]!= un[r*jmax + c]) ||
         (h_axi00_ptr0_output_vn[i]!= vn[r*jmax + c]) ||
         (h_axi00_ptr0_output_yn[i]!= yn[r*jmax + c]) 
         ){
        printf("ERROR,i=%d:: xn(e,a)=(%f,%f); un(e,a)=(%f,%f); vn(e,a)=(%f,%f); yn(e,a)=(%f,%f); \n"
          , i
        , xn[r*jmax + c], h_axi00_ptr0_output_xn[i]
        , un[r*jmax + c], h_axi00_ptr0_output_un[i]
        , vn[r*jmax + c], h_axi00_ptr0_output_vn[i]
        , yn[r*jmax + c], h_axi00_ptr0_output_yn[i]
          );
        check_status = 1;
      //}
    }
  }
  
  //-----------------------------
  //Compare times (if applicable)
  //-----------------------------
   printf("\n-------------------------------------------\n");
   printf("*CPU* kernel computation function took %g seconds \n"   , cpu_time_used.count());
   printf("*DEVICE* Kernel computation function took %g seconds \n", dev_time_used.count());
   printf("-------------------------------------------\n");
   
    //--------------------------------------------------------------------------
    // Shutdown and cleanup
    //-------------------------------------------------------------------------- 
    clReleaseMemObject(d_axi00_ptr0_input_x   );
    clReleaseMemObject(d_axi00_ptr0_input_u   );
    clReleaseMemObject(d_axi00_ptr0_input_v   );
    clReleaseMemObject(d_axi00_ptr0_input_y   );
    clReleaseMemObject(d_axi00_ptr0_output_xn );
    clReleaseMemObject(d_axi00_ptr0_output_un );
    clReleaseMemObject(d_axi00_ptr0_output_vn );
    clReleaseMemObject(d_axi00_ptr0_output_yn );

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
