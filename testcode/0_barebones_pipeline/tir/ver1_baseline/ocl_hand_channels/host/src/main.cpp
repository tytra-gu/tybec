#include "CL/opencl.h"
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <time.h>
#include <timer.h>
#include <math.h>
#include "timer.h"
#include "ACLHostUtils.h"


#define CHECK(X) assert(CL_SUCCESS == (X))
//#define BUFSIZE (32*1024*1024)
#define BUFSIZE     16

#define NITERATIONS 1

//Multiple Kernels
//------------------
#define NKERNELS  6
#define K_MEM_RD  0
#define K_A  			1
#define K_B  			2
#define K_C  			3
#define K_D  			4
#define K_MEM_WR  5


const unsigned char *binary = 0;

cl_platform_id    platform;
cl_device_id      device;
cl_context        context;
cl_command_queue* cqs;
cl_program        my_program;
cl_kernel*        lib_kernels;
cl_kernel         kernel_builtin;

//---------------------------------
int generate_random_int()
//---------------------------------
{
    return (rand());
}

//---------------------------------
void notify_print( const char* errinfo, const void* private_info, size_t cb, void *user_data )
//---------------------------------
{
   private_info = private_info;
   cb = cb;
   user_data = user_data;
   printf("Error: %s\n", errinfo);
}

//---------------------------------
unsigned char *load_file(const char* filename,size_t*size_ret)
//---------------------------------
{
   FILE* fp;
   int len;
   const size_t CHUNK_SIZE = 1000000;
   unsigned char *result;
   size_t r = 0;
   size_t w = 0;
   fp = fopen(filename,"rb");
   if ( !fp ) return 0;
   // Obtain file size.
   fseek(fp, 0, SEEK_END);
   len = ftell(fp);
   // Go to the beginning.
   fseek(fp, 0, SEEK_SET);
   // Allocate memory for the file data.
   result = (unsigned char*)malloc(len+CHUNK_SIZE);
   if ( !result )
   {
     fclose(fp);
     return 0;
   }
   // Read file.
   while ( 0 < (r=fread(result+w,1,CHUNK_SIZE,fp) ) )
   {
     w+=r;
   }
   fclose(fp);
   *size_ret = w;
   return result;
}

//---------------------------------
int main(int argc, char**argv) 
//---------------------------------
{
   int *data_in1;
   int *data_in2;
   int *data_out_lib;

   cl_mem input1 = 0;
   cl_mem input2 = 0;
   cl_mem output_lib = 0;
   cl_int status = 0;
   cl_int bin_status = 0;
   size_t bin_len = 0;
   int num_errs = 0;
   int i,j;

   //Platform and Device 
   //-------------------
   // Single Device for now
   CHECK( clGetPlatformIDs(1,&platform,0) );
   CHECK( clGetDeviceIDs(platform,CL_DEVICE_TYPE_ACCELERATOR,1,&device,0) );

   //::Context::
   //-------------------
   //We're running in "offline" compiler mode by default.
   // So no need to specify special compiler mode properties.
   context = clCreateContext( 0, 1, &device, notify_print, 0, &status );
   CHECK( status );
   
   //::Command queues::
   //-------------------
   //Create separate queue for each kernel, even if on same device
   for(i=0; i<NKERNELS; i++) {
    cqs[i] = clCreateCommandQueue( context, device, 0, &status );
    CHECK( status );
   }

   //::Load binary and create and build program(s)::
   //-------------------
   const unsigned char* my_binary;
   size_t my_binary_len = 0;

   //If we move to multiple devices, then there will be multiple binaries, one for each device 
   //and similarly multiple programs (or an array of programs)
   const char *aocx_name = "kernels.aocx";
   printf("Loading %s ...\n", aocx_name);
   my_binary = load_file(aocx_name, &my_binary_len); 

   if ((my_binary == 0) || (my_binary_len == 0))
   { 
     printf("Error: unable to read %s into memory or the file was not found!\n", aocx_name);
     exit(-1);
   }

   my_program = clCreateProgramWithBinary(context,1,&device,&my_binary_len,&my_binary,&bin_status,&status);
   CHECK(status);

   CHECK( clBuildProgram(my_program,1,&device,"",0,0) );

   //Creat kernel(s)
   //-------------------
   const char* kernel_names[NKERNELS] = 
    {
       "kernel_mem_rd"
      ,"cl_func_lib_kernel_A"
      ,"cl_func_lib_kernel_B"
      ,"cl_func_lib_kernel_C"
      ,"cl_func_lib_kernel_D"
      ,"kernel_mem_wr"
    };

   for (i=0;i<NKERNELS;i++) {
    lib_kernels[i] = clCreateKernel(my_program,kernel_names[i],&status);
    CHECK(status);
    printf("Kernel #%d created\n",i);
   }
   
   //Creat buffer(s) and init
   //---------------
   printf("Create buffers\n");
   input1 = clCreateBuffer(context,CL_MEM_READ_WRITE,BUFSIZE*sizeof(int),0,&status);
   CHECK(status);
   input2 = clCreateBuffer(context,CL_MEM_READ_WRITE,BUFSIZE*sizeof(int),0,&status);
   CHECK(status);
   output_lib     = clCreateBuffer(context,CL_MEM_READ_WRITE,BUFSIZE*sizeof(int),0,&status);
   CHECK(status);

   data_in1         = (int *) acl_aligned_malloc(BUFSIZE*sizeof(int));
   data_in2         = (int *) acl_aligned_malloc(BUFSIZE*sizeof(int));
   data_out_lib     = (int *) acl_aligned_malloc(BUFSIZE*sizeof(int));
   
   if ((data_in1 == NULL) || (data_in2 == NULL) || (data_out_lib == NULL))
   {
     printf("ERROR: Unable to allocate memory for data buffers.\n");
     exit(1);
   }
   
   printf("Generate data for conversion...\n");
   srand( 1 );   
   for ( i = 0; i < BUFSIZE ; i++ ) {
      data_in1[i] = i;//generate_random_int();
      data_in2[i] = i;//generate_random_int();
   }

   //Sizes
   //---------------
   //Global Size
   //N iterations in the kernel
   //So #work-items (global size) is BUFFSIZE/N
   //cl_int N = 1024;
   cl_int N = BUFSIZE;
   size_t dims[3] = {BUFSIZE/N, 0, 0};
   int NUM_ITERATIONS = NITERATIONS;
   printf("Enqueueing both library and builtin in kernels %d times with global size %d\n", 
          NUM_ITERATIONS, (int)dims[0]);

          
   //Set and Write Args 
   //---------------
   //read memory kernel
   CHECK( clSetKernelArg(lib_kernels[K_MEM_RD], 0, sizeof(cl_mem),&input1) );
   CHECK( clSetKernelArg(lib_kernels[K_MEM_RD], 1, sizeof(cl_mem),&input2) );
   
   //write memory kernel
   CHECK( clSetKernelArg(lib_kernels[K_MEM_WR], 0, sizeof(cl_mem),&output_lib) );

   //write input data to buffers
   CHECK( clEnqueueWriteBuffer(cqs[K_MEM_RD],input1,0,0,BUFSIZE*sizeof(int),data_in1,0,0,0) );
   CHECK( clEnqueueWriteBuffer(cqs[K_MEM_RD],input2,0,0,BUFSIZE*sizeof(int),data_in2,0,0,0) );
 
   CHECK( clFinish(cqs[K_MEM_RD]) );

   //Enqueue kernel(s)
   //-----------------
   Timer t_lib;
   t_lib.start();
   //multiple application runs?
   for (i = 0; i < NUM_ITERATIONS; i++) {
     //enqueue kernel(s)
     for (j = 0; j < NITERATIONS; j++) {
      CHECK( clEnqueueNDRangeKernel(cqs[j],lib_kernels[j],1,0,dims,0,0,0,0) );
     }
   }
   //TODO: Do I need to block here?
   //CHECK( clFinish(cqs));
   t_lib.stop();
   printf ("Kernel computation using library function took %g seconds\n", t_lib.get_time_s());
   
   //Read result(s)
   //--------------
   printf("Reading results to buffers...\n");
   
   CHECK( clEnqueueReadBuffer(cqs[K_MEM_WR],output_lib, 1,0,BUFSIZE*sizeof(int),data_out_lib,0,0,0) );
   
   CHECK( clFinish(cqs[K_MEM_WR]) );

//   printf("Checking results...\n");
   
//   int num_printed = 0;
//   for ( i = 0; i < BUFSIZE; i++ )
//   {
//     if (data_out_lib[i] != data_out_builtin[i]) {
//       num_errs++;
//       if (num_printed < 10) {
//         printf ("ERROR at i=%d, library = %g, builtin = %g\n", i, data_out_lib[i], data_out_builtin[i]);
//         num_printed++;
//       }
//     }
//   }

   clReleaseMemObject(input1);
   clReleaseMemObject(input2);
   clReleaseMemObject(output_lib);
   for(i=0;i<NKERNELS;i++) {
    clReleaseKernel(lib_kernels[i]);
   }
   clReleaseProgram(my_program);
   clReleaseContext(context);
   free(data_in1);
   free(data_in2);
   free(data_out_lib);
   //if ( num_errs > 0 ) { 
   //   printf("FAILED with %i errors.\n", num_errs);
   //} else {
   //   if ( fabs(time_ratio - 1) > 0.05 ) {
   //      printf ("FAILED because runtime ratio of library to builtin function is more than 5% (%g)\n", time_ratio);
   //   } else {
   //      printf("Library function throughput is within 5%% of builtin throughput.\n");
   //      printf("PASSED\n");
   //   }
   //}

   return 0;
}
