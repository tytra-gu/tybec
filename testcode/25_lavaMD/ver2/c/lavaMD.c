// =============================================================================
// Company      : Unversity of Glasgow, Comuting Science
// Author:        Syed Waqar Nabi
// 
// Create Date  : 2019.06.19
// Project Name : TyTra
//
// Dependencies : 
//
// Revision     : 
// Revision 0.01. File Created
// 
// Conventions  : 
// =============================================================================
//
// =============================================================================
// General Description
// -----------------------------------------------------------------------------
// Coriolis acceleration kernel, manually written in C
// to use for conversion to TIR via LLVM-IR
// =============================================================================

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#define ROWS  16
#define COLS  ROWS
#define SIZE  (ROWS*COLS)
//constants used in the design; assign randomly
#define a2    23

//data type
#define host_t int

#define NTOT 1

#define DOT(A,B) ((A.x)*(B.x)+(A.y)*(B.y)+(A.z)*(B.z))	// STABLE



//---------------------------------------------------------------------------
// kernel: tempIterate
//----------------------------------------------------------------------------
void lavaNeiLoop(
    host_t* rA_shared_v
  , host_t* rA_shared_x
  , host_t* rA_shared_y  
  , host_t* rA_shared_z
  , host_t* rB_shared_v
  , host_t* rB_shared_x
  , host_t* rB_shared_y
  , host_t* rB_shared_z
  , host_t* qB_shared
  , host_t* d_fv_gpu_v 
  , host_t* d_fv_gpu_x 
  , host_t* d_fv_gpu_y 
  , host_t* d_fv_gpu_z   
) {

  for (int j=0; j<= ROWS-1; j++) {
    for (int k=0; k<= COLS-1; k++) {  
      int M = j*COLS + k; //ME
			host_t r2 = rA_shared_v[M] + rB_shared_v[M] 
                - ((rA_shared_x[M])*(rB_shared_x[M])
                  +(rA_shared_y[M])*(rB_shared_y[M])
                  +(rA_shared_z[M])*(rB_shared_z[M]));
                //DOT(rA_shared[wtx],rB_shared[j]); 
			host_t u2 = a2*r2;
			//vij= exp(-u2);
			host_t vij  = u2*3;
			host_t fs   = 2*vij;
			host_t dx   = rA_shared_x[M]  - rB_shared_x[M];
			host_t fxij = fs*dx;
			host_t dy   = rA_shared_y[M]  - rB_shared_y[M];
			host_t fyij = fs*dy;
			host_t dz   = rA_shared_z[M]  - rB_shared_z[M];
			host_t fzij = fs*dz;
			d_fv_gpu_v[M] =  qB_shared[M]*vij;
			d_fv_gpu_x[M] =  qB_shared[M]*fxij;
			d_fv_gpu_y[M] =  qB_shared[M]*fyij;
			d_fv_gpu_z[M] =  qB_shared[M]*fzij;
    }
  }
}


//---------------------------------------------------------------------------
// main
//----------------------------------------------------------------------------
//quick and dirty, written in fortran-95 style with globals
void main (void) {
  
   const int ntot = NTOT; //how many time steps
   //const int nout = 5;    //log output after every how many steps?
   const int rows = ROWS;
   const int cols = COLS;
   const int BytesPerWord = sizeof(host_t);
  
  //host arrays
  host_t* rA_shared_v;
  host_t* rA_shared_x;
  host_t* rA_shared_y;
  host_t* rA_shared_z;
  host_t* rB_shared_v;
  host_t* rB_shared_x;
  host_t* rB_shared_y;
  host_t* rB_shared_z;
  host_t* qB_shared  ;
  host_t* d_fv_gpu_v ;
  host_t* d_fv_gpu_x ;
  host_t* d_fv_gpu_y ;
  host_t* d_fv_gpu_z ;

  rA_shared_v = malloc(SIZE*BytesPerWord);
  rA_shared_x = malloc(SIZE*BytesPerWord);
  rA_shared_y = malloc(SIZE*BytesPerWord);
  rA_shared_z = malloc(SIZE*BytesPerWord);
  rB_shared_v = malloc(SIZE*BytesPerWord);
  rB_shared_x = malloc(SIZE*BytesPerWord);
  rB_shared_y = malloc(SIZE*BytesPerWord);
  rB_shared_z = malloc(SIZE*BytesPerWord);
  qB_shared   = malloc(SIZE*BytesPerWord);
  d_fv_gpu_v  = malloc(SIZE*BytesPerWord);
  d_fv_gpu_x  = malloc(SIZE*BytesPerWord);
  d_fv_gpu_y  = malloc(SIZE*BytesPerWord);
  d_fv_gpu_z  = malloc(SIZE*BytesPerWord);

  //mock data to match init data in verilog TB
  for (int j=0; j<=ROWS-1; j++) {
    for (int k=0; k<=COLS-1; k++) {
      rA_shared_v [j*COLS + k]   = (host_t) j*COLS + k + 1;      
      rA_shared_x [j*COLS + k]   = (host_t) j*COLS + k + 1;      
      rA_shared_y [j*COLS + k]   = (host_t) j*COLS + k + 1;      
      rA_shared_z [j*COLS + k]   = (host_t) j*COLS + k + 1;      
      rB_shared_v [j*COLS + k]   = (host_t) j*COLS + k + 1;      
      rB_shared_x [j*COLS + k]   = (host_t) j*COLS + k + 1;      
      rB_shared_y [j*COLS + k]   = (host_t) j*COLS + k + 1;      
      rB_shared_z [j*COLS + k]   = (host_t) j*COLS + k + 1;      
      qB_shared   [j*COLS + k]   = (host_t) j*COLS + k + 1;      
      d_fv_gpu_v  [j*COLS + k]   = 0;      
      d_fv_gpu_x  [j*COLS + k]   = 0;      
      d_fv_gpu_y  [j*COLS + k]   = 0;      
      d_fv_gpu_z  [j*COLS + k]   = 0;      
    }
  }
  
  // simulation loop
  //-------------------------
  for (int i=0;i<ntot;i++) {  
    lavaNeiLoop(
        rA_shared_v
      , rA_shared_x
      , rA_shared_y  
      , rA_shared_z
      , rB_shared_v
      , rB_shared_x
      , rB_shared_y
      , rB_shared_z
      , qB_shared
      , d_fv_gpu_v 
      , d_fv_gpu_x 
      , d_fv_gpu_y 
      , d_fv_gpu_z   
    );
  }
  
  
  //output logging 
  //-------------------------
  //store results in hex for use in HDL sim verification
  //minimal lazy testing, just testing yn ##make sure HDL testbench are also using yn for verification##
  FILE *fp_verify_hex;  
  FILE *fp_verify;  
  fp_verify_hex = fopen("verifyChex.dat", "w");  
  fp_verify     = fopen("verifyC.dat", "w");  
	for (int lin=0;lin<SIZE;lin++){ 
      //fprintf (fp_verify_hex, "%x\n", yn[i][j]); //for integer outputs
      //fprintf (fp_verify_hex, "%x\n", yn[i][j]);  //for float outputs
      //following apparentlty violates the "strict aliasing rule" so may not always work?
      //https://stackoverflow.com/questions/45228925/how-to-print-float-as-hex-bytes-format-in-c?rq=1
      fprintf (fp_verify_hex, "%x\n", d_fv_gpu_v[lin]); 
      fprintf (fp_verify, "%d\n", d_fv_gpu_v[lin]);
  }
	printf("Hex results logged for HDL verification\n");
  fclose(fp_verify_hex);
  fclose(fp_verify);
}//main()


