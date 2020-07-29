#include "host-generic.h"

//====================================================
// Globals 
//====================================================
//array of randomized indices in both directions to simulate random access
//extern static int randi[ROWS],
//           randj[COLS];

//timing variables (defined in host.c)
extern  double time_write_to_device[NTIMES];
extern  double time_total_alltimesteps_kernels[NTIMES];
extern  double time_read_from_device[NTIMES];
extern  double time_total_alltimesteps_kernels_onhost;


static double avgtime = 0
            , maxtime = 0
            , relstdev = 0
            , mintime = FLT_MAX;

static const char  *label = "Kernel:      ";
//static double bytes = 2 * sizeof(data_t) * SIZE * NTOT;
static int    ops_per_wi = 52+27+6; //crude manual counting of FLOPS in 3 kernels
static double    total_ops  = (double) (ops_per_wi * SIZE * NTOT);


//double times[NTIMES];
//extern double time_write_to_device[NTIMES];
//extern double time_total_alltimesteps_kernels[NTIMES];
//extern double time_read_from_device[NTIMES];

//double time_a2d_togpu;
//double time_b2d_togpu;
//double time_kernels;
//double time_c2d_tohost;
//double time_write2file;
//double time_verify;


//====================================================
// load_file_to_memory()
//====================================================
int
load_file_to_memory(const char *filename, char **result)
{ 
  size_t size = 0;
  FILE *f = fopen(filename, "rb");
  if (f == NULL) 
  { 
    *result = NULL;
    return -1; // -1 means file opening fail 
  } 
  fseek(f, 0, SEEK_END);
  size = ftell(f); //current position
  fseek(f, 0, SEEK_SET);
  *result = (char *)malloc(size+1);
  if (size != fread(*result, sizeof(char), size, f)) 
  { 
    free(*result);
    return -2; // -2 means file reading fail 
  } 
  fclose(f);
  (*result)[size] = 0;
  return size;
}

//====================================================
// oclh_init_data()
//====================================================
void oclh_init_data(data_t* a2d, data_t* b2d, data_t* c2d, int BytesPerWord) {
  // Initializaing the stream arrays
  // --------------------------------
  //randomize a2d, so that persistent DRAM content does not lead to false positives when verifying results
  time_t tt;
  srand((unsigned) time(&tt));
  int r = rand() % 50; 

  for (int i=0; i<ROWS; i++) {
    for (int j=0; j<COLS; j++) {
      *(a2d + i*COLS + j) = r+i+j;
      *(b2d + i*COLS + j) = i+j;
      *(c2d + i*COLS + j) = 0.0;
    }
  }
  printf("Host arrays initialized. Random integer = %d\n", r);
  printf(HLINE);
}

//====================================================
// display setup()
//====================================================
void oclh_display_setup(){
 // Display experimental setup
  //---------------------------------------
  printf(SLINE);
  printf("Experimental Setup \n");
  printf(HLINE);
  printf("ROWS        = %d                                       \n", ROWS );
  printf("SIZE        = %d                                       \n", SIZE );
  printf("NTOT        = %d                                       \n", NTOT );
  printf("NTIMES      = %d                                       \n", NTIMES );
  printf(HLINE);
}


//====================================================
// oclh_opencl_boilerplate()
//====================================================
int  oclh_opencl_boilerplate ( cl_context*      context_ref
                            , cl_command_queue* commands_ref
                            , cl_program*       program_ref
                            , cl_kernel*        kernel_ref
                            , int               argc
                            , char**            argv
) {
  printf(SLINE);
  printf("OpenCL Setup \n");
  printf(HLINE);

  // -----------------------------------------
  // Error Handling
  // -----------------------------------------
  cl_int err = CL_SUCCESS;

  // -----------------------------------------
  // Init OpenCL variables
  // -----------------------------------------

  cl_uint           platformIdCount = 0; //# of platforms
  cl_uint           num_devices;
  cl_platform_id    platform_id;    // platform id
  cl_device_id*     all_device_ids; // compute device id (all devices)
  cl_device_id      device_id;      // compute device id (
  
  //for chrec
  cl_device_id      device_id0;      // compute device id 
  cl_device_id      device_id1;      // compute device id 

  cl_context        context = *context_ref;  // compute context
  cl_command_queue* commands= commands_ref; // compute command queue(s)
  //cl_program        program = *program_ref;  // compute program
  cl_program*       programs  = program_ref;  // compute programs
  cl_kernel*        kernels   = kernel_ref;   // compute kernels

//  cl_command_queue  commands= *commands_ref; // compute command queue
//  cl_kernel         kernel  = *kernel_ref;   // compute kernels

  char cl_platform_vendor[1001];
  char cl_platform_name[1001];
  char cl_platform_version[1001];
    
  if (argc != 2){
    printf("%s <inputfile>\n", argv[0]);
    return EXIT_FAILURE;
  }
  
  
  // -----------------------------------------
  // PLATFORM: Query and connect
  // -----------------------------------------
  // get number of platforms
  err = clGetPlatformIDs  ( 0
                          , NULL
                          , &platformIdCount
                          ); 
  CHECK_ERRORS(err,"");
  printf ("Number of platforms:\t%d\n", platformIdCount);

  // Connect to first platform
  err = clGetPlatformIDs  ( 1
                          ,&platform_id
                          ,NULL
                          );
  CHECK_ERRORS(err, "Error: Failed to find an OpenCL platform!\n");

  //get platform vendor
  err = clGetPlatformInfo ( platform_id
                          , CL_PLATFORM_VENDOR
                          , 1000
                          , (void *)cl_platform_vendor
                          , NULL
                          );
  CHECK_ERRORS(err, "Error: clGetPlatformInfo(CL_PLATFORM_VENDOR) failed!");
  printf("CL_PLATFORM_VENDOR:\t%s\n",cl_platform_vendor);

  //get platform name
  err = clGetPlatformInfo ( platform_id
                          , CL_PLATFORM_NAME
                          , 1000
                          , (void *)cl_platform_name
                          , NULL
                          );
  CHECK_ERRORS(err, "Error: clGetPlatformInfo(CL_PLATFORM_NAME) failed!");
  printf("CL_PLATFORM_NAME:\t%s\n",cl_platform_name);

  //get OpenCL platform version
  err = clGetPlatformInfo ( platform_id
                          , CL_PLATFORM_VERSION
                          , 1000
                          , (void *)cl_platform_version
                          , NULL
                          );
  CHECK_ERRORS(err, "Error: clGetPlatformInfo(CL_PLATFORM_VERSION) failed!");
  printf("CL_PLATFORM_VERSION:\t%s\n",cl_platform_version);

  // -----------------------------------------
  // DEVICE: Query, connect and display info
  // -----------------------------------------
  // Connect to compute device
  //
  //get number of devices
  
  printf(HLINE);
  printf("Device details\n");
  printf(HLINE);
  err = clGetDeviceIDs  ( platform_id
                        , CL_DEVICE_TYPE_ALL
                        , 0
                        , NULL
                        , &num_devices
                        );
  CHECK_ERRORS(err, "Query for number of devices failed");
  
  //#if TARGET==AOCL_CHREC
  //  printf("NUMBER OF NOVOG DEVICES:\t%d\n",num_devices);
  //  if (num_devices > 2) {
  //    fprintf(stderr, "Currently only 2 devices supported for AOCL_CHREC target\n");
  //    exit(EXIT_FAILURE);
  //  }        
  //#else
  //  printf("NUMBER OF DEVICES:\t%d\n",num_devices);
  //#endif    
  
  //*** Choosing the right device target ****
  //It looks like the way the host is compiled and linked, only the
  //the relevant FPGA device is visible, so we can essentially just
  //pick the first device, and it should work for AOCL and SDACCEL
  //but this is not robust. 
  all_device_ids = new cl_device_id[num_devices];

  //test
  //#if TARGET==AOCL
  //  printf("TARGET = AOCL\n");
  //#elif TARGET==AOCL_CHREC
  //  printf("TARGET = AOCL_CHREC\n");
  //#elif TARGET==SDACCEL
  //  printf("TARGET = SDACCEL\n");
  //#elif TARGET==CPU
  //  printf("TARGET = CPU (Intel)\n");
  //#elif TARGET==GPU
  //  printf("TARGET = GPU (NVIDIA)\n");
  //#else
  //  #error Invalid TARGET definition.
  //#endif 

  //Pick devices for different types of targets
  //#if (TARGET == GPU)
  //  err = clGetDeviceIDs  ( platform_id
  //                        , CL_DEVICE_TYPE_GPU
  //                        , num_devices
  //                        , all_device_ids
  //                        , NULL
  //                        );
  //  device_id = all_device_ids[0]; //pick the first device
  ////FPGA targets (Identified as Accelerators)
  //#elif (TARGET == SDACCEL) || (TARGET == AOCL)
    err = clGetDeviceIDs  ( platform_id
                          , CL_DEVICE_TYPE_ACCELERATOR
                          , num_devices
                          , all_device_ids
                          , NULL
                          );
    device_id = all_device_ids[0]; //pick the first device
  //#elif (TARGET == AOCL_CHREC)
  //  err = clGetDeviceIDs  ( platform_id
  //                        , CL_DEVICE_TYPE_ACCELERATOR
  //                        , num_devices
  //                        , all_device_ids
  //                        , NULL
  //                        );
  //  //pick the first 2 devices. This application version is limited to 2 devices
  //  device_id0 = all_device_ids[0]; 
  //  device_id1 = all_device_ids[1]; 
  //  
  //#elif (TARGET == CPU)
  //  err = clGetDeviceIDs  ( platform_id
  //                        , CL_DEVICE_TYPE_CPU
  //                        , num_devices
  //                        , all_device_ids
  //                        , NULL
  //                        );
  //  device_id = all_device_ids[0]; //pick the first device
  //#else
  //  #error Inbvalid device.    
  //#endif

  CHECK_ERRORS(err, "Error: Failed to create a device group!\n");
  printf("DEVICE ID:\t\t%d\n",device_id);

  OCLBASIC_PRINT_TEXT_PROPERTY    (CL_DEVICE_NAME                         );
  OCLBASIC_PRINT_TEXT_PROPERTY    (CL_DEVICE_VENDOR                       );
  OCLBASIC_PRINT_NUMERIC_PROPERTY (CL_DEVICE_VENDOR_ID                    , cl_uint );
  OCLBASIC_PRINT_TEXT_PROPERTY    (CL_DEVICE_VERSION                      );
  OCLBASIC_PRINT_TEXT_PROPERTY    (CL_DRIVER_VERSION                      );
  OCLBASIC_PRINT_NUMERIC_PROPERTY (CL_DEVICE_ADDRESS_BITS                 , cl_uint );
  OCLBASIC_PRINT_NUMERIC_PROPERTY (CL_DEVICE_AVAILABLE                    , cl_bool );
  OCLBASIC_PRINT_NUMERIC_PROPERTY (CL_DEVICE_ENDIAN_LITTLE                , cl_bool );
  OCLBASIC_PRINT_NUMERIC_PROPERTY (CL_DEVICE_GLOBAL_MEM_CACHE_SIZE        , cl_ulong);
  OCLBASIC_PRINT_NUMERIC_PROPERTY (CL_DEVICE_GLOBAL_MEM_CACHELINE_SIZE    , cl_uint );
  OCLBASIC_PRINT_NUMERIC_PROPERTY (CL_DEVICE_GLOBAL_MEM_SIZE              , cl_ulong);
  OCLBASIC_PRINT_NUMERIC_PROPERTY (CL_DEVICE_IMAGE_SUPPORT                , cl_bool );
  OCLBASIC_PRINT_NUMERIC_PROPERTY (CL_DEVICE_LOCAL_MEM_SIZE               , cl_ulong);
  OCLBASIC_PRINT_NUMERIC_PROPERTY (CL_DEVICE_MAX_CLOCK_FREQUENCY          , cl_uint);
  OCLBASIC_PRINT_NUMERIC_PROPERTY (CL_DEVICE_MAX_COMPUTE_UNITS            , cl_uint);
  OCLBASIC_PRINT_NUMERIC_PROPERTY (CL_DEVICE_MAX_CONSTANT_ARGS            , cl_uint);
  OCLBASIC_PRINT_NUMERIC_PROPERTY (CL_DEVICE_MAX_CONSTANT_BUFFER_SIZE     , cl_ulong);
  OCLBASIC_PRINT_NUMERIC_PROPERTY (CL_DEVICE_MAX_WORK_ITEM_DIMENSIONS     , cl_uint );
  //OCLBASIC_PRINT_NUMERIC_PROPERTY (CL_DEVICE_MAX_WORK_GROUP_SIZE          , cl_uint );
  OCLBASIC_PRINT_NUMERIC_PROPERTY (CL_DEVICE_MEM_BASE_ADDR_ALIGN          , cl_uint );
  OCLBASIC_PRINT_NUMERIC_PROPERTY (CL_DEVICE_MIN_DATA_TYPE_ALIGN_SIZE     , cl_uint );
  OCLBASIC_PRINT_NUMERIC_PROPERTY (CL_DEVICE_PREFERRED_VECTOR_WIDTH_CHAR  , cl_uint );
  OCLBASIC_PRINT_NUMERIC_PROPERTY (CL_DEVICE_PREFERRED_VECTOR_WIDTH_SHORT , cl_uint );
  OCLBASIC_PRINT_NUMERIC_PROPERTY (CL_DEVICE_PREFERRED_VECTOR_WIDTH_INT   , cl_uint );
  OCLBASIC_PRINT_NUMERIC_PROPERTY (CL_DEVICE_PREFERRED_VECTOR_WIDTH_LONG  , cl_uint );
  OCLBASIC_PRINT_NUMERIC_PROPERTY (CL_DEVICE_PREFERRED_VECTOR_WIDTH_FLOAT , cl_uint );
  OCLBASIC_PRINT_NUMERIC_PROPERTY (CL_DEVICE_PREFERRED_VECTOR_WIDTH_DOUBLE, cl_uint );
  
  printf(HLINE);

  // -----------------------------------------
  // Create a compute context 
  // -----------------------------------------
  context = clCreateContext ( 0
                            , num_devices
                            , all_device_ids
                            , NULL
                            , NULL
                            , &err
                            );

//  context = clCreateContext ( 0
//                            , 1
//                            , &device_id
//                            , NULL
//                            , NULL
//                            , &err
//                            );
  CHECK_ERRORS(err, "Error: Failed to create a compute context!\n");
  printf("Context creation:\tOK\n");



  // -----------------------------------------
  // Command Queue(s)
  // -----------------------------------------
  for (int i=0; i<NKERNELS; i++) {
    commands[i] = clCreateCommandQueue  ( context
                                        , device_id
                                        , 0
                                        , &err
                                        );
    CHECK_ERRORS(err, "Error: Failed to create a command commands!\n");
    printf("Command Queue creation # %d:\tOK\n",i);
    printf(HLINE); 
  }

  // -----------------------------------------
  // Create Program Objects, and Build
  // -----------------------------------------
  // Target specific code fragments follow
  // For FPGA Kernel build happens offline
  // Load binary from disk 
  // binary already built by aocl/sdaccel
  //-------------------------------------------------------------------------
//#if (TARGET == AOCL) || (TARGET == SDACCEL)
    unsigned char *kernelbinary;
    char *fpgabin=argv[1];
    //kernel is passed as the argument
    //load kernel binary from file into memory
    printf("OCLH: loading %s\n", fpgabin);
    int n_i = load_file_to_memory(fpgabin, (char **) &kernelbinary);   
    
    if (n_i < 0) {
      printf("Error: Failed to load kernel from fpga-bin: %s\n", fpgabin);
      return EXIT_FAILURE;
    }
    size_t n = n_i;
    
    // Create the compute program from offline compiled binary
    programs[0] = clCreateProgramWithBinary ( context
                                        , 1
                                        , &device_id
                                        , &n
                                        , (const unsigned char **) &kernelbinary
                                        , NULL
                                        , &err
                                        );
    if ((!programs[0]) || (err!=CL_SUCCESS)) {
      printf("OCLH: Error: Failed to create compute program from binary %d!\n", err);
      return EXIT_FAILURE;
    }
    
    err = clBuildProgram  ( programs[0]
                          , 0
                          , NULL
                          , NULL
                          , NULL
                          , NULL
                          );

    if (err != CL_SUCCESS) {
      size_t len;
      char buffer[2048];
      
      printf("Error %d : Failed to build program executable!\n", err);
      clGetProgramBuildInfo(programs[0], device_id, CL_PROGRAM_BUILD_LOG, 2048, buffer, NULL);
      printf("%s\n", buffer);
      printf("Test failed\n");
      exit(-1);
      return EXIT_FAILURE;
    }
  //-------------------------------------------------------------------------
//#elif (TARGET==AOCL_CHREC)
//    // NOTE:: When passing arguments to exe, I have to pass BOTH (or more) kernel files 
//    // in the correct sequence
//    for (int i=0; i<num_devices; i++) {
//      unsigned char *kernelbinary;
//      char *fpgabin=argv[i+1];
//      //kernel is passed as the argument
//      //load kernel binary from file into memory
//      printf("OCLH: loading %s\n", fpgabin);
//      int n_i = load_file_to_memory(fpgabin, (char **) &kernelbinary);   
//      
//      if (n_i < 0) {
//        printf("Error: Failed to load kernel from fpga-bin: %s\n", fpgabin);
//        return EXIT_FAILURE;
//      }
//      
//      //<<TOCONTINUE::Use this loop to create separate programs. Then go down  an udpate Build program and opther folliwing code as needed for novog.
//      //First test this code on si ngle device (bolama/ibm) as it should still work there. Then later on try it on novog >>
//      
//      //NOTE: When the devices are not longer symmetrical (e.g. you do distribute different task/kernels to different devices), 
//      //then you need to build  different kernels for each device. One approach is to have different opencl "programs" for each 
//      //device. That means you create an array of programs, and then loop through the devices, and call the clCreateProgramWithBinary 
//      //for each device. Another option is to use a single call (and create a single "program"), as opencl allows passing arrays to this call. 
//      
//      programs[i] = clCreateProgramWithBinary ( context
//                                              , 1
//                                              , all_device_ids[i]
//                                              , &n
//                                              , (const unsigned char **) &kernelbinary
//                                              , NULL
//                                              , &err
//                                              );
//    
//    
//      err = clBuildProgram ( programs[i]
//                          , 0
//                          , NULL
//                          , NULL
//                          , NULL
//                          , NULL
//                          );
//                          
//      //Build failure
//      if (err != CL_SUCCESS) {
//        size_t len;
//        char buffer[2048];
//        
//        printf("Error %d : Failed to build program executable!\n", err);
//        clGetProgramBuildInfo(programs[i], device_id, CL_PROGRAM_BUILD_LOG, 2048, buffer, NULL);
//        printf("%s\n", buffer);
//        printf("Test failed\n");
//        exit(-1);
//        return EXIT_FAILURE;
//      }                               
//    }//for
//
//  //-------------------------------------------------------------------------
//#elif (TARGET == CPU) || (TARGET == GPU)
//    char *clsource=argv[1];
//    printf("OCLH: Reading kernel source: %s\n", clsource);
//    
//    std::ifstream in (clsource);
//    std::string result  ( (std::istreambuf_iterator<char> (in))
//                        , std::istreambuf_iterator<char> ()
//                        );
//    size_t lengths [1] = { result.size () };
//    const char* sources [1] = { result.data () };
//    programs[0] = clCreateProgramWithSource ( context
//                                            , 1
//                                            , sources
//                                            , lengths
//                                            , &err
//                                            );
//    CHECK_ERRORS (err,"");
//    printf("OCLH: Created program with source: %s\n", clsource);
//
//    err = clBuildProgram  ( programs[0]
//                          , 0
//                          , NULL
//                          , NULL
//                          , NULL
//                          , NULL
//                          );
//    
//    if (err != CL_SUCCESS) {
//      size_t len;
//      char buffer[2048];
//      
//      printf("Error %d : Failed to build program executable!\n", err);
//      clGetProgramBuildInfo(programs[0], device_id, CL_PROGRAM_BUILD_LOG, 2048, buffer, NULL);
//      printf("%s\n", buffer);
//      printf("Test failed\n");
//      exit(-1);
//      return EXIT_FAILURE;
//    }
//  //-------------------------------------------------------------------------
//    #else
//      #error Invalid TARGET.
//    #endif
  
  //-------------------------------------------------------------------------
  
  printf("OCLH: Program built\n");
  

  // -----------------------------------------
  // Create Kernel
  // -----------------------------------------
  
//#ifdef SINGLEWI_KERNEL
////------------------------------------------------------
//  #ifdef USECHANNELS
////------------------------------------------------------
//    const char* kernel_names[NKERNELS] = 
//      {
//         "kernel_mem_rd"
//        ,"kernel_smache_memrd_2_dyn1"
//        ,"kernel_dyn1"
//        ,"kernel_smache_dyn1_2_dyn2"
//        ,"kernel_dyn2"
//        ,"kernel_smache_dyn2_2_shapiro"
//        ,"kernel_shapiro"
//        ,"kernel_updates"
//        ,"kernel_mem_wr"
//      };
//  #else
//------------------------------------------------------
    const char* kernel_names[NKERNELS] = 
      {
        "Kernel"
      };
//  #endif
//#endif
//------------------------------------------------------

//#ifdef NDRANGE_KERNEL
////------------------------------------------------------
//  const char* kernel_names[NKERNELS] = 
//    {
//       "kernel_dyn1"
//      ,"kernel_dyn2"
//      ,"kernel_shapiro"
//      ,"kernel_updates"
//    };
//#endif
//------------------------------------------------------

//#if TARGET==AOCL_CHREC
//  //There is a 1-1 mapping between device-id for a kernel and 
//  //the program-id relevant for it. So we pick up the device id
//  //and use it as the index into the array of programs
//  int did=0;
//  for (int i=0; i<NKERNELS; i++) {
//    switch(i) {
//      case K_MEM_RD  				      : did = D4_K_MEM_RD  				      ; break;
//      case K_SMACHE_MEMRD_2_DYN1	: did = D4_K_SMACHE_MEMRD_2_DYN1  ; break;
//      case K_DYN1    				      : did = D4_K_DYN1    				      ; break;
//      case K_SMACHE_DYN1_2_DYN2	  : did = D4_K_SMACHE_DYN1_2_DYN2	  ; break;
//      case K_DYN2    				      : did = D4_K_DYN2    				      ; break;
//      case K_SMACHE_DYN2_2_SHAPIRO: did = D4_K_SMACHE_DYN2_2_SHAPIRO; break;
//      case K_SHAPIRO 				      : did = D4_K_SHAPIRO 				      ; break;
//      case K_UPDATES 				      : did = D4_K_UPDATES 				      ; break;
//      case K_MEM_WR  				      : did = D4_K_MEM_WR  				      ; break;
//    }
//
//    kernels[i] = clCreateKernel ( programs[did]
//                                , kernel_names[i]
//                                , &err
//                                );
//    if (!kernels[i] || err != CL_SUCCESS) {
//      printf("OCLH: Error: Failed to create compute kernel # %d\n", i);
//      return EXIT_FAILURE;
//    }
//    printf("OCLH: Kernel created # %d\n",i);
//  }
//
//#else
  for (int i=0; i<NKERNELS; i++) {
    kernels[i] = clCreateKernel ( programs[0]
                                , kernel_names[i]
                                , &err
                                );
    if (!kernels[i] || err != CL_SUCCESS) {
      printf("OCLH: Error: Failed to create compute kernel # %d\n", i);
      return EXIT_FAILURE;
    }
    printf("OCLH: Kernel created # %d\n",i);
  }
//#endif    

  //update the opencl variables in the main's scope, as the local ones will
  //go out of scope
  *context_ref  = context ;       // compute context
  commands_ref = commands;       // compute command queue
  program_ref  = programs ;       // compute program
  kernel_ref   = kernels ;       // compute kernel
}//oclh_opencl_boilerplate

//====================================================
// oclh_create_device_buffer()
//====================================================
void oclh_create_cldevice_buffer ( cl_mem*        buffer
                                 , cl_context*    context
                                 , cl_mem_flags   flag
) {                              
  // Create buffer and copy data
  // -----------------------------------------
  // Create the input and output arrays in device memory for our calculation  
  //*buffer = clCreateBuffer(*context, CL_MEM_READ_ONLY,  sizeof(data_t) * SIZE, NULL, NULL);
  *buffer = clCreateBuffer(*context, flag,  sizeof(data_t) * SIZE, NULL, NULL);

  if (!(*buffer)) {
    CHECK_ERRORS(-1, "OCLH:Error: Failed to allocate device memory!");
  }
  printf("OCLH: Created a buffer of size %d bytes in device memory\n", SIZE);

}

//====================================================
// oclh_blocking_write_cl_buffer()
//====================================================
void oclh_blocking_write_cl_buffer ( cl_command_queue*  commands
                                  , cl_mem*             dbuffer
                                  , data_t*          hbuffer
) {
  cl_int   err = CL_SUCCESS;
  cl_event writeevent;
  //write array to device memory for 
  //----------------------------
//  err = clEnqueueWriteBuffer  ( *commands
  err = clEnqueueWriteBuffer  ( commands[0]
                              , *dbuffer
                              , CL_TRUE
                              , 0
                              , sizeof(data_t) * SIZE
                              , hbuffer
                              , 0
                              , NULL
                              , &writeevent);
  CHECK_ERRORS(err, "OCLH: Error: Failed to write to source array a!");
  clWaitForEvents(1, &writeevent);  
}


//====================================================
// oclh_blocking_read_cl_buffer()
//====================================================
void oclh_blocking_read_cl_buffer ( cl_command_queue* commands
                                  , cl_mem*           dbuffer
                                  , data_t*        hbuffer
) {
  cl_int   err = CL_SUCCESS;
  cl_event readevent;

//read array from device memory (same buffer to which we wrote)
//----------------------------

//if we are using channels, then we read from the last kernel...
#ifdef USECHANNELS
    err = clEnqueueReadBuffer (commands[K_MEM_WR]
#else 
    err = clEnqueueReadBuffer (commands[0]
#endif      
                              , *dbuffer
                              , CL_TRUE
                              , 0
                              , sizeof(data_t) * SIZE
                              , hbuffer
                              , 0
                              , NULL
                              , &readevent );  
    CHECK_ERRORS(err, "Error: Failed to read output array!");
    clWaitForEvents(1, &readevent);
}


//====================================================
// oclh_set_kernel_args()
//====================================================

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
                          ){
  cl_int   err = CL_SUCCESS;
//
//#ifdef SINGLEWI_KERNEL
//  //if using channels, then even with SINGLEWI there are multiple kernels
//  //two additional kernels for reading and writing from memory as well
//   #ifdef USECHANNELS
//    err  = clSetKernelArg(kernels[K_MEM_RD], 0, sizeof(cl_mem), dev_u);
//    err |= clSetKernelArg(kernels[K_MEM_RD], 1, sizeof(cl_mem), dev_v);
//    err |= clSetKernelArg(kernels[K_MEM_RD], 2, sizeof(cl_mem), dev_h);
//    err |= clSetKernelArg(kernels[K_MEM_RD], 3, sizeof(cl_mem), dev_eta);
//    err |= clSetKernelArg(kernels[K_MEM_RD], 4, sizeof(cl_mem), dev_etan);
//    err |= clSetKernelArg(kernels[K_MEM_RD], 5, sizeof(cl_mem), dev_wet);
//    err |= clSetKernelArg(kernels[K_MEM_RD], 6, sizeof(cl_mem), dev_hzero);
//
//    err |= clSetKernelArg(kernels[K_DYN1], 0, sizeof(data_t),  (void *) dt);
//    err |= clSetKernelArg(kernels[K_DYN1], 1, sizeof(data_t),  (void *) dx);
//    err |= clSetKernelArg(kernels[K_DYN1], 2, sizeof(data_t),  (void *) dy);
//    err |= clSetKernelArg(kernels[K_DYN1], 3, sizeof(data_t),  (void *) g);
//
//    err |= clSetKernelArg(kernels[K_DYN2], 0, sizeof(data_t),  (void *) dt);
//    err |= clSetKernelArg(kernels[K_DYN2], 1, sizeof(data_t),  (void *) dx);
//    err |= clSetKernelArg(kernels[K_DYN2], 2, sizeof(data_t),  (void *) dy);
//
//    err |= clSetKernelArg(kernels[K_SHAPIRO], 0, sizeof(data_t),  (void *) eps);
//
//    err |= clSetKernelArg(kernels[K_UPDATES], 0, sizeof(data_t),  (void *) hmin);   
//    
//    //only for TG4IK, where I want update kernel to acces hzero directly from gmem
//    //#define TG4IK
//    #ifdef TG4IK
//    printf("OCLH: Running the TG4IK version\n");
//    err |= clSetKernelArg(kernels[K_UPDATES], 1, sizeof(cl_mem)   ,  (void *) dev_hzero); 
//    #endif  
//
//    err |= clSetKernelArg(kernels[K_MEM_WR], 0, sizeof(cl_mem), dev_u);
//    err |= clSetKernelArg(kernels[K_MEM_WR], 1, sizeof(cl_mem), dev_v);
//    err |= clSetKernelArg(kernels[K_MEM_WR], 2, sizeof(cl_mem), dev_h);
//    err |= clSetKernelArg(kernels[K_MEM_WR], 3, sizeof(cl_mem), dev_eta);
//    err |= clSetKernelArg(kernels[K_MEM_WR], 4, sizeof(cl_mem), dev_wet);
//  //single-wi with no channels, so just a single kernel
//  #else
    err  = clSetKernelArg(kernels[0], 0, sizeof(data_t),  (void *) dt);
    err |= clSetKernelArg(kernels[0], 1, sizeof(data_t),  (void *) dx);
    err |= clSetKernelArg(kernels[0], 2, sizeof(data_t),  (void *) dy);
    err |= clSetKernelArg(kernels[0], 3, sizeof(data_t),  (void *) g);
    err |= clSetKernelArg(kernels[0], 4, sizeof(data_t),  (void *) eps);
    err |= clSetKernelArg(kernels[0], 5, sizeof(data_t),  (void *) hmin);
    err |= clSetKernelArg(kernels[0], 6, sizeof(cl_mem),     dev_eta);
    err |= clSetKernelArg(kernels[0], 7, sizeof(cl_mem),     dev_un);
    err |= clSetKernelArg(kernels[0], 8, sizeof(cl_mem),     dev_u);
    err |= clSetKernelArg(kernels[0], 9, sizeof(cl_mem),     dev_wet);
    err |= clSetKernelArg(kernels[0],10, sizeof(cl_mem),     dev_v);
    err |= clSetKernelArg(kernels[0],11, sizeof(cl_mem),     dev_vn);
    err |= clSetKernelArg(kernels[0],12, sizeof(cl_mem),     dev_h);
    err |= clSetKernelArg(kernels[0],13, sizeof(cl_mem),     dev_etan);
    err |= clSetKernelArg(kernels[0],14, sizeof(cl_mem),     dev_hzero);
  //  err |= clSetKernelArg(kernels[0],15, sizeof(int),        (void *) rows);
  //  err |= clSetKernelArg(kernels[0],16, sizeof(int),        (void *) cols);
//  #endif
//#endif

////nd-range kernel (currently only without channels), multiple kernels
//#ifdef NDRANGE_KERNEL
//  err  = clSetKernelArg(kernels[K_DYN1], 0, sizeof(data_t),  (void *) dt);
//  err |= clSetKernelArg(kernels[K_DYN1], 1, sizeof(data_t),  (void *) dx);
//  err |= clSetKernelArg(kernels[K_DYN1], 2, sizeof(data_t),  (void *) dy);
//  err |= clSetKernelArg(kernels[K_DYN1], 3, sizeof(data_t),  (void *) g);
//  err |= clSetKernelArg(kernels[K_DYN1], 4, sizeof(cl_mem),     dev_eta);
//  err |= clSetKernelArg(kernels[K_DYN1], 5, sizeof(cl_mem),     dev_un);
//  err |= clSetKernelArg(kernels[K_DYN1], 6, sizeof(cl_mem),     dev_u);
//  err |= clSetKernelArg(kernels[K_DYN1], 7, sizeof(cl_mem),     dev_wet);
//  err |= clSetKernelArg(kernels[K_DYN1], 8, sizeof(cl_mem),     dev_v);
//  err |= clSetKernelArg(kernels[K_DYN1], 9, sizeof(cl_mem),     dev_vn);
////  err |= clSetKernelArg(kernels[K_DYN1],10, sizeof(int),        (void *) rows);
////  err |= clSetKernelArg(kernels[K_DYN1],11, sizeof(int),        (void *) cols);
//
//  err  = clSetKernelArg(kernels[K_DYN2], 0, sizeof(data_t),  (void *) dt);
//  err |= clSetKernelArg(kernels[K_DYN2], 1, sizeof(data_t),  (void *) dx);
//  err |= clSetKernelArg(kernels[K_DYN2], 2, sizeof(data_t),  (void *) dy);
//  err |= clSetKernelArg(kernels[K_DYN2], 3, sizeof(cl_mem),     dev_eta);
//  err |= clSetKernelArg(kernels[K_DYN2], 4, sizeof(cl_mem),     dev_un);
//  err |= clSetKernelArg(kernels[K_DYN2], 5, sizeof(cl_mem),     dev_u);
//  err |= clSetKernelArg(kernels[K_DYN2], 6, sizeof(cl_mem),     dev_v);
//  err |= clSetKernelArg(kernels[K_DYN2], 7, sizeof(cl_mem),     dev_vn);
//  err |= clSetKernelArg(kernels[K_DYN2], 8, sizeof(cl_mem),     dev_h);
//  err |= clSetKernelArg(kernels[K_DYN2], 9, sizeof(cl_mem),     dev_etan);
////  err |= clSetKernelArg(kernels[K_DYN2],10, sizeof(int),        (void *) rows);
////  err |= clSetKernelArg(kernels[K_DYN2],11, sizeof(int),        (void *) cols);
//
//  err  = clSetKernelArg(kernels[K_SHAPIRO], 0, sizeof(data_t),  (void *) eps);
//  err |= clSetKernelArg(kernels[K_SHAPIRO], 1, sizeof(cl_mem),     dev_etan);
//  err |= clSetKernelArg(kernels[K_SHAPIRO], 2, sizeof(cl_mem),     dev_wet);
//  err |= clSetKernelArg(kernels[K_SHAPIRO], 3, sizeof(cl_mem),     dev_eta);
////  err |= clSetKernelArg(kernels[K_SHAPIRO], 4, sizeof(int),        (void *) rows);
////  err |= clSetKernelArg(kernels[K_SHAPIRO], 5, sizeof(int),        (void *) cols);
//
//  err  = clSetKernelArg(kernels[K_UPDATES], 0, sizeof(cl_mem),     dev_h);
//  err |= clSetKernelArg(kernels[K_UPDATES], 1, sizeof(cl_mem),     dev_hzero);
//  err |= clSetKernelArg(kernels[K_UPDATES], 2, sizeof(cl_mem),     dev_eta);
//  err |= clSetKernelArg(kernels[K_UPDATES], 3, sizeof(cl_mem),     dev_u);
//  err |= clSetKernelArg(kernels[K_UPDATES], 4, sizeof(cl_mem),     dev_un);
//  err |= clSetKernelArg(kernels[K_UPDATES], 5, sizeof(cl_mem),     dev_v);
//  err |= clSetKernelArg(kernels[K_UPDATES], 6, sizeof(cl_mem),     dev_vn);
//  err |= clSetKernelArg(kernels[K_UPDATES], 7, sizeof(cl_mem),     dev_wet);
//  err |= clSetKernelArg(kernels[K_UPDATES], 8, sizeof(data_t),  (void *) hmin);
////  err |= clSetKernelArg(kernels[K_UPDATES], 9, sizeof(int),        (void *) rows);
////  err |= clSetKernelArg(kernels[K_UPDATES],10, sizeof(int),        (void *) cols);
//                                            
//#endif                                        
  
  CHECK_ERRORS(err, "Error: Failed to set kernel arguments!");
}


//====================================================
// oclh_get_global_local_sizes()
//====================================================
void oclh_get_global_local_sizes ( size_t* globalSize
                                , size_t* localSize
){
  // --- GLOBAL SIZE ---------
  //API-looping over work-items handled by enquing multiple work-items
  //#if (LOOPING==API)
  //  globalSize[0] = (SIZE / VECTOR_SIZE) ;
  //Kernel-looping (explicit). Single work-item launched via API, looping here
  //#elif (LOOPING==KERNEL)
  globalSize[0] = 1 ;

    
  //#else
  //  #error Undefined LOOPING.
  //#endif
  printf("Global size = %d \n", globalSize[0]);
//  printf("Local Size = NULL\n");
  
  // LOCAL SIZE -----------
  //FPGA
/*
  #ifdef REQ_WORKGROUP_SIZE
    size_t temp[] = {REQ_WORKGROUP_SIZE};
    localSize[0] = temp[0];
    localSize[1] = temp[1];
    localSize[2] = temp[2];
    #define LOCAL_SIZE localSize
    printf("Local Size = %d, %d, %d\n", localSize[0], localSize[1], localSize[2]);
  #else
    #define LOCAL_SIZE NULL
  #endif
*/
  localSize[0] = 1;
  printf("Local Size = %d \n", localSize[0]);
  
}

//====================================================
// oclh_enq_cl_kernel()
//====================================================
void oclh_enq_cl_kernel (  cl_command_queue* commands
                         , cl_kernel*        kernels
                         , size_t*           globalSize
                         , size_t*           localSize
) {
    cl_int   err = CL_SUCCESS;
    cl_event kernelevent;
    // ------------------
    // Kernel(s)
    // ------------------    
    
  for (int i=0; i<NKERNELS; i++) {
    err = clEnqueueTask(*commands, kernels[i], 0, NULL, NULL);
    //err = clEnqueueNDRangeKernel  ( *commands 
    //                              , kernels[i]
    //                              , 1
    //                              , NULL
    //                              , globalSize
    //                              , localSize
    //                              //, NULL
//  //                                , LOCAL_SIZE
    //                              , 0
    //                              , NULL
    //                              , &kernelevent
    //                              );
    //
    ////clWaitForEvents(1, &kernelevent);  
  }//for()
}//()

//====================================================
// oclh_log_results
//====================================================
void oclh_log_results ( data_t* eta
                      , data_t* h
                      , data_t* h_g
                      , data_t* u
                      , data_t* v
                      , data_t* h0
){
  printf("OCLH: Logging data <variable>.dat\n");
  FILE * feta;
  FILE * fh;
  FILE * fh_g;
  FILE * fh_c;
  FILE * fu;
  FILE * fv;
  FILE * fh0;
  feta= fopen ("eta.dat","w");
  fh  = fopen ("h.dat","w");
  fh_g= fopen ("hgold.dat","w");
  fu  = fopen ("u.dat","w");
  fv  = fopen ("v.dat","w");
  fh0 = fopen ("h0.dat","w");
  fh_c= fopen ("hcompare.dat","w");

  const int ROWS_TO_LOG = 1;
  //for (int i = 0; i < ROWS; ++i) {
  for (int i = 0; i < ROWS_TO_LOG; ++i) {
    for (int j = 0; j < COLS; ++j) {
      
      fprintf(feta,"%d,  ", *(eta+ i*COLS + j));
      fprintf(fh  ,"%d,  ", *(h  + i*COLS + j));
      fprintf(fh_g,"%d,  ", *(h_g+ i*COLS + j));
      fprintf(fu  ,"%d,  ", *(u  + i*COLS + j));
      fprintf(fv  ,"%d,  ", *(v  + i*COLS + j));
      fprintf(fh0 ,"%d,  ", *(h0 + i*COLS + j));
      fprintf(fh_c,"(c%d,e%d) ,  ", *(h + i*COLS + j), *(h_g + i*COLS + j));
    }//j
    fprintf(feta,"\n");
    fprintf(fh  ,"\n");
    fprintf(fh_g,"\n");
    fprintf(fu  ,"\n");
    fprintf(fv  ,"\n");
    fprintf(fh0 ,"\n");
    fprintf(fh_c,"\n");
  }//i
  fclose(feta);  
  fclose(fh);  
  fclose(fh_g);  
  fclose(fu);  
  fclose(fv);  
  fclose(fh0);  
  fclose(fh_c);  
  printf("OCLH: Results from device written to DAT files\n");  
}

//====================================================
// oclh_verify_results()
//====================================================
int oclh_verify_results ( data_t* h
                        , data_t* h_g
){
  // verify results
  // -----------------------------------------
  printf(SLINE);

  data_t gold;
  data_t val;
  data_t diff;
  data_t eps;

  for (int i = 0; i < ROWS; ++i)
    for (int j = 0; j < COLS; ++j) {     

      gold = *(h_g + i*COLS + j);
      val  = *(h   + i*COLS + j);
      diff = fabs(gold - val);
      eps  = EPSILON;

      if ( fabs(gold - val) > eps ) {
      printf("*** TEST FAILED ***. Device results do not match HOST computed results!\n");
      printf("At failure, i = %d, j = %d, expected = %d, computed = %d, diff = %d, and EPSILON = %d\n"
              , i
              , j
              , gold
              , val
	      , diff
              , eps
           );
        return EXIT_FAILURE;
      }//if
      else {
/*
      	printf("Correct result @ i = %d, j = %d, expected value = %d, computed value = %d\n"
              , i
              , j
              , gold
              , val

           );
*/
      }//else
    }//for
  printf("*** TEST PASSED ***. Device results match locally computed results!\n");
  return(1);
//
}

