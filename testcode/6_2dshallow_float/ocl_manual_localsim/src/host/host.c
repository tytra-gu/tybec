// ======================================================
// WN, Glasgow, 2109.12.04
// 2d shallow water manual opencl for sdx-based implementation
// ======================================================

//------------------------------------------
// DATA TYPE AND PROBLEM SIZE
// opencl boiler plate helpers
//------------------------------------------
#include "host-generic.h"

//------------------------------------------
// initialize 2D shallow-water host arrays
//------------------------------------------
void sw2d_init_data_host ( data_t *hzero
                    , data_t *eta  
                    , data_t *etan 
                    , data_t *h    
                    , data_t *wet  
                    , data_t *u    
                    , data_t *un   
                    , data_t *v    
                    , data_t *vn
                    , data_t hmin
                    , int BytesPerWord
                    ) {
      
//FILE * fdebug;
//fdebug= fopen ("debug.dat","w");

  int j, k;

  //to match the (naive)values in TIR version
  //----------------------------------------
  for (j=0; j<=ROWS-1; j++) {
    for (k=0; k<=COLS-1; k++) {
      hzero[j*COLS + k] = j*COLS + k + 1;
      h[j*COLS + k]     = j*COLS + k + 1;
      wet[j*COLS + k]   = 1;
      eta[j*COLS + k]   = j*COLS + k + 1;
      u[j*COLS + k]     = j*COLS + k + 1;
      v[j*COLS + k]     = j*COLS + k + 1;

      etan[j*COLS + k]  = j*COLS + k + 1;
      un[j*COLS + k]    = j*COLS + k + 1;
      vn[j*COLS + k]    = j*COLS + k + 1;
    }
  }


  //realistic initialiation
  //----------------------------------------
#if 0  
  //initialize height
  for (j=0; j<=ROWS-1; j++) {
    for (k=0; k<=COLS-1; k++) {
      hzero[j*COLS + k] = 10.0;
    }
  }

  //land boundaries with 10 m elevation
  for (k=0; k<=COLS-1; k++) {
    //top-row
    hzero[0*COLS + k] = -10.0;
    //bottom-row (ROWS-1)
    hzero[(ROWS-1)*COLS + k] = -10.0;
  }
  for (j=0; j<=ROWS-1; j++) {
    //left-most-col
    hzero[j*COLS + 0] = -10.0;
    //right-most-col
    hzero[j*COLS + COLS-1] = -10.0;
  }

  // eta and etan
  for (j=0; j<= ROWS-1; j++) {
    for (k=0; k<=COLS-1; k++) {
      eta [j*COLS + k] = -MIN(0.0, hzero[j*COLS + k] );
      etan[j*COLS + k] = eta[j*COLS + k];
//      fprintf(fdebug, "j = %d, k = %d, eta = %f\n"
//                       ,j, k, eta[j*COLS + k]);
    }                                                                           
  } 

  //h, wet, u, un, v, vn
  // eta and etan
  for (j=0; j<= ROWS-1; j++) {
    for (k=0; k<= COLS-1; k++) {
      //h
      h[j*COLS + k] = hzero[j*COLS + k] 
                    +   eta[j*COLS + k];
      //wet                   
      //wet = 1 defines "wet" grid cells 
      //wet = 0 defines "dry" grid cells (land)
//temp-for-debug
//    wet[j*COLS + k] = j*COLS + k +1; 

      
//#if 0
      wet[j*COLS + k] = 1; 
      if (h[j*COLS + k] < hmin)
       wet[j*COLS + k] = 0; 
//#endif
      //u, v, un, vn
      u [j*COLS + k] = 0;
      un[j*COLS + k] = 0;
      v [j*COLS + k] = 0;
      vn[j*COLS + k] = 0;

//printf("HOST-INIT:j = %d, k = %d,  wet = %f\n"
//               , j, k, wet[j*COLS + k]
//      );

    }
  }

  //Initial Condition... Give eta=1 @ MID_POINT
  //-------------------------------------------
  *(eta+ XMID*COLS + YMID) = 1.0;


 printf("Host arrays initialized.\n");
 printf(HLINE);

 //fclose(fdebug);  
#endif 
}

// -------------------------------------
// Globals
// -------------------------------------
  //timing variables
  double time_write_to_device[NTIMES];
  double time_total_alltimesteps_kernels[NTIMES];
  double time_read_from_device[NTIMES];
  double time_write2file;
  double time_total_alltimesteps_kernels_onhost;


// -------------------------------------
int main(int argc, char** argv) {
// -------------------------------------
  using namespace std;
  // =============================================================================
  // Generic Opencl/Local variables
  // =============================================================================
  double    t;
  int       k;
  int       BytesPerWord = sizeof(data_t);
  ssize_t   i,j;

  //for timing profile
  double start_timer, end_timer;

  printf(SLINE); 
  printf(SLINE);  
  printf("2D shallow water heterogenuous opencl model $\n"); printf(HLINE);
  printf(SLINE); 

// =============================================================================
// CONSTANTS
// =============================================================================
   int ntot = NTOT; //how many time steps
   int nout = 5;    //log output after every how many steps?
   int rows = ROWS;
   int cols = COLS;
  
  //scalars-int
   //data_t hmin = 0.05;
   //data_t dx = 10.0;
   //data_t dy = 10.0;
   //data_t dt = 0.1;
   //data_t g = 9.81;  
   //data_t eps = 0.05;
   //data_t hmin_g = 0.05; //golden copies not really needed, but to avoid bugs
   //data_t dx_g = 10.0;
   //data_t dy_g = 10.0;
   //data_t dt_g = 0.1;
   //data_t g_g = 9.81;  
   //data_t eps_g = 0.05;
   
   //scalars-float
   data_t dx      =1 ;  
   data_t dy      =2 ;
   data_t dt      =3 ;
   data_t g       =10;
   data_t eps     =5 ;
   data_t hmin    =5 ;
   data_t dx_g    =1 ;  
   data_t dy_g    =2 ;
   data_t dt_g    =3 ;
   data_t g_g     =10;
   data_t eps_g   =5 ;
   data_t hmin_g  =5 ;




// =============================================================================
// Do a HOST-only, GOLDEN run (this is always done, irrespective of target)
// =============================================================================
  printf(SLINE); 
  printf ("*** HOST Run ***\n");
  printf(SLINE); 

  //arrays
  data_t *hzero_g, *eta_g  ,*etan_g ,*h_g    ,*wet_g  ,*u_g    ,*un_g   ,*v_g    ,*vn_g;   

  posix_memalign ((void**)&eta_g  , ALIGNMENT, SIZE*BytesPerWord);
  posix_memalign ((void**)&etan_g , ALIGNMENT, SIZE*BytesPerWord);
  posix_memalign ((void**)&h_g    , ALIGNMENT, SIZE*BytesPerWord);
  posix_memalign ((void**)&hzero_g, ALIGNMENT, SIZE*BytesPerWord);
  posix_memalign ((void**)&wet_g  , ALIGNMENT, SIZE*BytesPerWord);
  posix_memalign ((void**)&u_g    , ALIGNMENT, SIZE*BytesPerWord);
  posix_memalign ((void**)&un_g   , ALIGNMENT, SIZE*BytesPerWord);
  posix_memalign ((void**)&v_g    , ALIGNMENT, SIZE*BytesPerWord);
  posix_memalign ((void**)&vn_g   , ALIGNMENT, SIZE*BytesPerWord);

  //initialize arrays
  //-------------------------
  sw2d_init_data_host(hzero_g, eta_g, etan_g, h_g, wet_g, u_g, un_g, v_g, vn_g, hmin, BytesPerWord);

  // determine maximum water depth
  data_t hmax_g= 0.0;
  for (int j=1; j<= COLS-2; j++) {
    for (int k=1; k<=ROWS-2; k++) {
      hmax_g = MAX (hmax_g, *(h_g + j+COLS + k));
    }
  }
  //maximum phase speed
  data_t c_g = sqrt(2*g*hmax_g);
  
  //determine stability parameter
  data_t lambda_g = dt*sqrt(g*hmax_g)/MIN(dx,dy);
  
//  printf ("Host: starting time loop for host run\n");
//  start_timer = mysecond();
//  for (int i=0;i<ntot;i++) {  
//    //call dyn (host version)
//    //-------------------------
//    sw2d_dyn_host(dt, dx, dy, g, eta_g, un_g, u_g, wet_g, v_g, vn_g, h_g, etan_g, BytesPerWord); 
//  
//    //call shapiro (host version)
//    //---------------------------
//    sw2d_shapiro_host(wet_g, etan_g, eps_g, eta_g);
//
//    //call updates (host version. in the original this is done in main)
//    //-------------------------------------------------------------------
//    sw2d_updates_host  (h_g , hzero_g, eta_g, u_g, un_g, v_g, vn_g, wet_g, hmin_g);
//  }
//  
//  end_timer = mysecond();
//  time_total_alltimesteps_kernels_onhost = end_timer - start_timer;
//  printf ("Host: host execution complete.\n");

  
  printf(SLINE); 
  printf ("OCL: *** OpenCL Run ***\n");
  printf(SLINE); 

// =============================================================================
// DEVICE RUN: 
// (includes APPLICATION execution loop; if we want multiple observations)
// =============================================================================


  //opencl variables
  cl_int            err = CL_SUCCESS;
  cl_context        context;            // compute context
  //cl_program        program;            // compute program
  cl_program        programs[NPROGRAMS];            // compute program(s)
  cl_command_queue  commands[NKERNELS]; // compute command queue
  cl_kernel         kernels[NKERNELS];  // compute kernels
//  cl_command_queue  commands;           // compute command queue
//  cl_kernel         kernel;         // compute kernels

  // =============================================================================
  // Application-specific Opencl variables
  // =============================================================================
  //device buffers
  cl_mem 
     dev_hzero
    ,dev_eta  
    ,dev_etan 
    ,dev_h    
    ,dev_wet  
    ,dev_u    
    ,dev_un   
    ,dev_v    
    ,dev_vn;

  //arrays
  data_t *hzero,*eta  ,*etan ,*h    ,*wet  ,*u    ,*un   ,*v    ,*vn;   

  posix_memalign ((void**)&hzero, ALIGNMENT, SIZE*BytesPerWord);
  posix_memalign ((void**)&eta  , ALIGNMENT, SIZE*BytesPerWord);
  posix_memalign ((void**)&etan , ALIGNMENT, SIZE*BytesPerWord);
  posix_memalign ((void**)&h    , ALIGNMENT, SIZE*BytesPerWord);
  posix_memalign ((void**)&wet  , ALIGNMENT, SIZE*BytesPerWord);
  posix_memalign ((void**)&u    , ALIGNMENT, SIZE*BytesPerWord);
  posix_memalign ((void**)&un   , ALIGNMENT, SIZE*BytesPerWord);
  posix_memalign ((void**)&v    , ALIGNMENT, SIZE*BytesPerWord);
  posix_memalign ((void**)&vn   , ALIGNMENT, SIZE*BytesPerWord);


  //initialize host arrays
  //-------------------------
  //needs to happen again as host run would have made some arrays dirty
  sw2d_init_data_host(hzero, eta, etan, h, wet, u, un, v, vn, hmin, BytesPerWord);
  //write initial distribution of eta 
#ifdef LOGRESULTS
  FILE * feta0;
  feta0= fopen ("eta0.dat","w");
  for (int i = 0; i < ROWS; ++i) {
    for (int j = 0; j < COLS; ++j) {    
      fprintf(feta0,"%f,  ", *(eta+ i*COLS + j));
    }//j
    fprintf(feta0,"\n");
  }//i
  fclose(feta0);  
#endif  
  
  // determine maximum water depth
  data_t hmax= 0.0;
  for (int j=1; j<= COLS-2; j++) {
    for (int k=1; k<=ROWS-2; k++) {
      hmax = MAX (hmax, *(h + j+COLS + k));
    }
  }
  
  //maximum phase speed
  data_t c = sqrt(2*g*hmax);
  
  //determine stability parameter
  data_t lambda = dt*sqrt(g*hmax)/MIN(dx,dy);
  printf("c = %f, lambda = %f\n", c, lambda);


// =============================================================================
// Setup for OCL if applicable
// =============================================================================
  //checks clock precision etc 
  //oclh_timing_setup(u,  BytesPerWord);

  //display setup
  oclh_display_setup();

  //initialize opencl; create context, commansds, program, and kernel
  //oclh_opencl_boilerplate(&context, &commands, &program, &kernel, argc, argv);
  //oclh_opencl_boilerplate(&context, &commands, &program, kernels, argc, argv);
  //oclh_opencl_boilerplate(&context, commands, &program, kernels, argc, argv);
  oclh_opencl_boilerplate(&context, commands, programs, kernels, argc, argv);
  
  //create read-write buffers of size SIZE on device
  oclh_create_cldevice_buffer(&dev_hzero, &context, CL_MEM_READ_WRITE);
  oclh_create_cldevice_buffer(&dev_eta  , &context, CL_MEM_READ_WRITE);
  oclh_create_cldevice_buffer(&dev_h    , &context, CL_MEM_READ_WRITE);
  oclh_create_cldevice_buffer(&dev_wet  , &context, CL_MEM_READ_WRITE);
  oclh_create_cldevice_buffer(&dev_u    , &context, CL_MEM_READ_WRITE);
  oclh_create_cldevice_buffer(&dev_v    , &context, CL_MEM_READ_WRITE);
  oclh_create_cldevice_buffer(&dev_etan , &context, CL_MEM_READ_WRITE); //not needed when using channels?
  oclh_create_cldevice_buffer(&dev_un   , &context, CL_MEM_READ_WRITE); //not needed when using channels?
  oclh_create_cldevice_buffer(&dev_vn   , &context, CL_MEM_READ_WRITE); //not needed when using channels?

    //-----------------------------------------------
    // Write arrays to device memory, if applicable
    //-----------------------------------------------
    //NOTE: the host-device transfer is OUTSIDE time loop of the application
    //      but INSIDE the NTIMES loop as we want to run multiple, independent 
    //      experiments.

//==============================================================================
for (int run=0; run<NTIMES; run++) {
//==============================================================================
printf(SLINE); printf("Application Run # %d\n",run+1);

    sw2d_init_data_host(hzero, eta, etan, h, wet, u, un, v, vn, hmin, BytesPerWord);


    // Record times 
    //start_timer = mysecond();
    oclh_blocking_write_cl_buffer(commands, &dev_hzero, hzero);
    oclh_blocking_write_cl_buffer(commands, &dev_eta  , eta  );
    oclh_blocking_write_cl_buffer(commands, &dev_etan , etan );
    oclh_blocking_write_cl_buffer(commands, &dev_h    , h    );
    oclh_blocking_write_cl_buffer(commands, &dev_wet  , wet  );
    oclh_blocking_write_cl_buffer(commands, &dev_u    , u    );
    oclh_blocking_write_cl_buffer(commands, &dev_un   , un   );
    oclh_blocking_write_cl_buffer(commands, &dev_v    , v    );
    oclh_blocking_write_cl_buffer(commands, &dev_vn   , vn   );

    //end_timer = mysecond();
    //time_write_to_device[run] = end_timer - start_timer;

    //printf("OCLH: Device buffers written\n");

  //-----------------------------------------------
  // Set args, global/local sizes (OCL only)
  //-----------------------------------------------
  //set the arguments 
  oclh_set_kernel_args  ( kernels
                        , &dt
                        , &dx
                        , &dy
                        , &g
                        , &eps
                        , &hmin
                        , &dev_eta
                        , &dev_un
                        , &dev_u
                        , &dev_wet
                        , &dev_v
                        , &dev_vn
                        , &dev_h
                        , &dev_etan
                        , &dev_hzero
//                        , &rows
//                        , &cols                        
                    );
  //printf("OCLH: Arguments set\n");
  //end_timer = mysecond();
  //time_write_to_device[run] = end_timer - start_timer;

  //set global and local sizes
  size_t globalSize[] = {0,0,0};
  size_t localSize[]  = {0,0,0};
  oclh_get_global_local_sizes(globalSize, localSize);

// ========================================================================
// TIME LOOP (Kernel Execution)
// ========================================================================
      cl_int err = CL_SUCCESS;
      printf("Starting time loop \n"); 
      //start_timer = mysecond();
      // top level (time) loop is on the host
      auto start = std::chrono::high_resolution_clock::now();          //<----------TIMER START
      for (int i=0;i<ntot;i++) {
        //oclh_enq_cl_kernel(commands, kernels, globalSize, localSize);
        err = clEnqueueTask(commands[0], kernels[0], 0, NULL, NULL);
        if (err) {
                printf("Error: Failed to execute kernel! %d\n", err);
                printf("Test failed\n");
                return EXIT_FAILURE;
            }        
        clFinish(commands[i]);
      }
      //One complete execution of application (all time steps)  ends here
      auto finish = std::chrono::high_resolution_clock::now();          //<----------TIMER END
      std::chrono::duration<double> dev_time_used = finish - start;
      printf("*DEVICE* Kernel computation function took %g seconds \n", dev_time_used.count());      

// ========================================================================
      //end_timer = mysecond();
      //time_total_alltimesteps_kernels[run] = end_timer - start_timer;
      //times[k] = mysecond() - times[k];

    //-------------------------------------------
    // Read back the results
    //-------------------------------------------
    //start_timer = mysecond();

    printf("Reading from device buffers\n");
    oclh_blocking_read_cl_buffer(commands, &dev_eta, eta);
    oclh_blocking_read_cl_buffer(commands, &dev_h  , h);
    oclh_blocking_read_cl_buffer(commands, &dev_u  , u);
    oclh_blocking_read_cl_buffer(commands, &dev_v  , v);
    //end_timer = mysecond();
    //time_read_from_device[run] = end_timer - start_timer;
    printf("End of Run\n"); printf(HLINE);
}//for (run=0; k<NTIMES; k++)

  // =============================================================================
  // POST PROCESSING
  // ============================================================================= 
  //log only once after all NTIMES loops. 
  oclh_log_results(eta, h, h_g, u, v, hzero);
  
  //clReleaseObject(dev_hzero);
  //clReleaseObject(dev_eta  );
  //clReleaseObject(dev_etan );
  //clReleaseObject(dev_h    );
  //clReleaseObject(dev_wet  );
  //clReleaseObject(dev_u    );
  //clReleaseObject(dev_un   );
  //clReleaseObject(dev_v    );
  //clReleaseObject(dev_vn   );
  // Calculate BW. Display and write to file
  //oclh_calculate_performance();
  //oclh_verify_results(h, h_g);
  
  //print some results

  for (int  i=0; i<NPROGRAMS; i++)
    clReleaseProgram(programs[i]);
  //clReleaseKernel(kernel); 
  //clReleaseCommandQueue(commands);

  clReleaseContext(context);

  free(hzero);
  free(eta  );
  free(etan );
  free(h    );
  free(wet  );
  free(u    );
  free(un   );
  free(v    );
  free(vn    );


//   
//   // Write output arrays 
//#ifdef LOGRESULTS
//#endif

//   //verify results
//   start_timer = mysecond();

//   end_timer = mysecond();
//   time_verify = end_timer - start_timer;
// 

 
   // Display overall timing profile 
   //oclh_disp_timing_profile();

// Shutdown and cleanup
// -----------------------------------------
  free(hzero_g);
  free(eta_g  );
  free(etan_g );
  free(h_g    );
  free(wet_g  );
  free(u_g    );
  free(un_g   );
  free(v_g    );
  free(vn_g    );

  printf(SLINE); 
  printf("Executable ends\n");
  printf(SLINE); 


}

