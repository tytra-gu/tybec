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
#define BUFSIZE 16

const unsigned char *binary = 0;

cl_platform_id platform;
cl_device_id device;
cl_context context;
cl_command_queue cq;
cl_program my_program;
cl_kernel kernel_lib;
cl_kernel kernel_builtin;

int generate_random_int()
{
    return (rand());
}


void notify_print( const char* errinfo, const void* private_info, size_t cb, void *user_data )
{
   private_info = private_info;
   cb = cb;
   user_data = user_data;
   printf("Error: %s\n", errinfo);
}

unsigned char *load_file(const char* filename,size_t*size_ret)
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

int main(int argc, char**argv) 
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
   int i;

   CHECK( clGetPlatformIDs(1,&platform,0) );
   CHECK( clGetDeviceIDs(platform,CL_DEVICE_TYPE_ACCELERATOR,1,&device,0) );

   // We're running in "offline" compiler mode by default.
   // So no need to specify special compiler mode properties.
   context = clCreateContext( 0, 1, &device, notify_print, 0, &status );
   CHECK( status );

   cq = clCreateCommandQueue( context, device, 0, &status );
   CHECK( status );

   const unsigned char* my_binary;
   size_t my_binary_len = 0;

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

   kernel_lib = clCreateKernel(my_program,"cl_func_lib",&status);
   CHECK(status);

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
   
   printf("Generate random data for conversion...\n");
   srand( 1 );   
   for ( i = 0; i < BUFSIZE ; i++ ) {
      data_in1[i] = generate_random_int();
      data_in2[i] = generate_random_int();
   }

   //Global Size
   //N iterations in the kernel
   //So #work-items (global size) is BUFFSIZE/N
   //cl_int N = 1024;
   cl_int N = BUFSIZE;
   
   CHECK( clSetKernelArg(kernel_lib,0,sizeof(cl_mem),&input1) );
   CHECK( clSetKernelArg(kernel_lib,1,sizeof(cl_mem),&input2) );
   CHECK( clSetKernelArg(kernel_lib,2,sizeof(cl_mem),&output_lib) );
   CHECK( clSetKernelArg(kernel_lib,3,sizeof(cl_int),&N) );

   CHECK( clEnqueueWriteBuffer(cq,input1,0,0,BUFSIZE*sizeof(int),data_in1,0,0,0) );
   CHECK( clEnqueueWriteBuffer(cq,input2,0,0,BUFSIZE*sizeof(int),data_in2,0,0,0) );

   size_t dims[3] = {BUFSIZE/N, 0, 0};
   int NUM_ITERATIONS = 1;
   printf("Enqueueing both library and builtin in kernels %d times with global size %d\n", 
          NUM_ITERATIONS, (int)dims[0]);
 
   CHECK( clFinish(cq) );

 
   Timer t_lib;
   t_lib.start();
   for (i = 0; i < NUM_ITERATIONS; i++) {
     CHECK( clEnqueueNDRangeKernel(cq,kernel_lib,1,0,dims,0,0,0,0) );
   }
   CHECK( clFinish(cq) );
   t_lib.stop();
   printf ("Kernel computation using library function took %g seconds\n", t_lib.get_time_s());
   
   printf("Reading results to buffers...\n");
   
   CHECK( clEnqueueReadBuffer(cq,output_lib,    1,0,BUFSIZE*sizeof(int),data_out_lib,0,0,0) );
   
   CHECK( clFinish(cq) );

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
   clReleaseKernel(kernel_lib);
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
