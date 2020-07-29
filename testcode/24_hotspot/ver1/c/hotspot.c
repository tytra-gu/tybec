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

#define ROWS          16
#define COLS          ROWS
#define SIZE          (ROWS*COLS)
#define step_div_Cap  43
#define Rx_1          12
#define Ry_1          22 
#define Rz_1          56
#define amb_temp      65

//data type
#define host_t int

#define NTOT 1

//---------------------------------------------------------------------------
// kernel: tempIterate
//----------------------------------------------------------------------------
void tempIterate(
   host_t* temp_t_out
  ,host_t* temp_t_in
  ,host_t* power
) {

  //indices
  int M, N, S, W, E;

  for (int j=1; j<= ROWS-2; j++) {
    for (int k=1; k<= COLS-2; k++) {  
      M = j*COLS + k; //ME
      N = M-COLS;
      S = M+COLS;
      E = M+1;
      W = M-1;
      
			temp_t_out[M] = temp_t_in[M] 
                        + step_div_Cap 
                        * (power[M] 
                          + (temp_t_in[S] 
                            + temp_t_in[N] 
                            - 2 * temp_t_in[M])
                          * Ry_1 
                          + (temp_t_in[E] 
                            + temp_t_in[W] 
                            - 2 * temp_t_in[M]) 
                          * Rx_1 
//swapping operands as silly limitation in TIR does not allow constants as second operands                          
//                          + (amb_temp 
//                            - temp_t_in[M]) 
                          + (temp_t_in[M]
                            - amb_temp ) 
                          * Rz_1
                          )
                        ;      
      
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
  host_t  *temp_t_out
         ,*temp_t_in  
         ,*power
         ;
  temp_t_out  = malloc(SIZE*BytesPerWord);
  temp_t_in   = malloc(SIZE*BytesPerWord);
  power       = malloc(SIZE*BytesPerWord);

  //mock data to match init data in verilog TB
  for (int j=0; j<=ROWS-1; j++) {
    for (int k=0; k<=COLS-1; k++) {
      temp_t_in [j*COLS + k]   = (host_t) j*COLS + k + 1;      
      power     [j*COLS + k]   = (host_t) j*COLS + k + 1;      
      temp_t_out[j*COLS + k]   = 0;      
    }
  }
  
  // simulation loop
  //-------------------------
  for (int i=0;i<ntot;i++) {  
    tempIterate  (temp_t_out , temp_t_in, power);
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
      fprintf (fp_verify_hex, "%x\n", temp_t_out[lin]); 
      fprintf (fp_verify, "%d\n", temp_t_out[lin]);
  }
	printf("Hex results logged for HDL verification\n");
  fclose(fp_verify_hex);
  fclose(fp_verify);
}//main()


