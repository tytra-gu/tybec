//dyn1 only for unit testing

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#define EPSILON 0.1
#define NTOT    1
#define ROWS    8
#define COLS    ROWS
#define NX      (ROWS-2)
#define NY      (COLS-2)
#define XMID    (NX/2)
#define YMID    (NY/2)
#define SIZE   (ROWS*COLS)

#define ALIGNMENT 64

#define host_t int
//#define host_t float

#define FXS 100
  //fix-point scaling (so that our code is "integer" version only)

//as ABS not currently implemented in TyBEC, so remove it here too for result compatibility  
#define abs  
  
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
  
// =========================
// Signatures
// =========================
void init_data (  host_t *etan 
                , host_t *wet
                , host_t *eta  
                , int BytesPerWord
                ) ;

void shapiro ( host_t *wet 
             , host_t *etan
             , host_t eps
             , host_t *eta
             );


void log_results ( host_t* eta_g
                 );
                
// =========================
// Main
// =========================

int main(int argc, char** argv) {
 
// ======================================================================
// CONSTANTS
// ======================================================================
   const int ntot = NTOT; //how many time steps
   const int nout = 5;    //log output after every how many steps?
   const int rows = ROWS;
   const int cols = COLS;
   const int BytesPerWord = sizeof(host_t);

  //scalars (actual)
  // host_t hmin    = (host_t) (FXS* 0.05);
  // host_t dx      = (host_t) (FXS* 10.0);
  // host_t dy      = (host_t) (FXS* 10.0);
  // host_t dt      = (host_t) (FXS* 0.1 );
  // host_t g       = (host_t) (FXS* 9.81);  
  // host_t eps     = (host_t) (FXS* 0.05);
  // host_t hmin_g  = (host_t) (FXS* 0.05); //golden copies not really needed, but to avoid bugs
  // host_t dx_g    = (host_t) (FXS* 10.0);
  // host_t dy_g    = (host_t) (FXS* 10.0);
  // host_t dt_g    = (host_t) (FXS* 0.1 );
  // host_t g_g     = (host_t) (FXS* 9.81);  
  // host_t eps_g   = (host_t) (FXS* 0.05);

  //for integer unit testing
   host_t hmin    = (host_t) (FXS* 0.05); //unused
   host_t dx      = (host_t) 1;
   host_t dy      = (host_t) 2;
   host_t dt      = (host_t) 3;
   host_t g       = (host_t) 10;  
   host_t eps     = (host_t) 5;
   //golden copies not really needed, but to avoid bugs
   host_t hmin_g  = (host_t) (FXS* 0.05); //unused
   host_t dx_g    = (host_t) 1;
   host_t dy_g    = (host_t) 2;
   host_t dt_g    = (host_t) 3;
   host_t g_g     = (host_t) 10;  
   host_t eps_g   = (host_t) 5;

   
// ======================================================================
// Host run
// ======================================================================
  printf ("*** HOST Run ***\n");
   
  //arrays
  host_t  *hzero_g
            ,*eta_g  
            ,*etan_g 
            ,*h_g    
            ,*wet_g  
            ,*u_g    
            ,*un_g   
            ,*v_g    
            ,*vn_g
            ;   

  eta_g  =malloc(SIZE*BytesPerWord);
  etan_g =malloc(SIZE*BytesPerWord);
  h_g    =malloc(SIZE*BytesPerWord);
  hzero_g=malloc(SIZE*BytesPerWord);
  wet_g  =malloc(SIZE*BytesPerWord);
  u_g    =malloc(SIZE*BytesPerWord);
  un_g   =malloc(SIZE*BytesPerWord);
  v_g    =malloc(SIZE*BytesPerWord);
  vn_g   =malloc(SIZE*BytesPerWord);

  //initialize arrays
  //-------------------------
  //------------------------------------------
  
  init_data(  etan_g 
            , wet_g
            , eta_g //eta_g output for shapiro
            , BytesPerWord
            );
                
  // determine parameters
  //-------------------------
  
  // determine maximum water depth
  host_t hmax_g= (int) 0.0;
  for (int j=1; j<= COLS-2; j++) {
    for (int k=1; k<=ROWS-2; k++) {
      hmax_g = MAX (hmax_g, *(h_g + j+COLS + k));
    }
  }
  //maximum phase speed
  host_t c_g = sqrt(2*g*hmax_g);
  
  //determine stability parameter
  host_t lambda_g = dt*sqrt(g*hmax_g)/MIN(dx,dy);
  
  printf ("Host: starting time loop for host run\n");

  // simulation loop
  //-------------------------
  for (int i=0;i<ntot;i++) {  
    //dyn2(dt, dx, dy, g, eta_g, un_g, vn_g, h_g, etan_g, BytesPerWord); 
    shapiro(wet_g, etan_g, eps_g, eta_g);
    //updates  (h_g , hzero_g, eta_g, u_g, un_g, v_g, vn_g, wet_g, hmin_g);
  }
  
  // log results
  //-------------------------
  log_results(eta_g);

}//main()



//------------------------------------------
// initialize 2D shallow-water host arrays
//------------------------------------------

void init_data (  host_t *etan  
                , host_t *wet 
                , host_t *eta
                , int BytesPerWord
                ) {
      
//FILE * fdebug;
//fdebug= fopen ("debug.dat","w");

  int j, k;

  //mock data to match init data in verilog TB
  for (j=0; j<=ROWS-1; j++) {
    for (k=0; k<=COLS-1; k++) {
      etan[j*COLS + k] = (host_t) j*COLS + k + 1;
      wet[j*COLS + k]  = 1;
      
      eta[j*COLS + k]  = (host_t) j*COLS + k + 1;
        //since tir sets eta to etan in both top and nested branch (i.e., boundary, as well as wet dependent branch)
        //whereas this code only sets etan in one branch (boundary), I set it to etan at the beginning here
    }
  }
  
/* ORIGINAL  
  //initialize height
  for (j=0; j<=ROWS-1; j++) {
    for (k=0; k<=COLS-1; k++) {
      hzero[j*COLS + k] = (int) FXS * 10.0;
    }
  }

  //land boundaries with 10 m elevation
  for (k=0; k<=COLS-1; k++) {
    //top-row
    hzero[0*COLS + k] = (int) FXS * -10.0;
    //bottom-row (ROWS-1)
    hzero[(ROWS-1)*COLS + k] = (int) FXS * -10.0;
  }
  for (j=0; j<=ROWS-1; j++) {
    //left-most-col
    hzero[j*COLS + 0] = (int) FXS * -10.0;
    //right-most-col
    hzero[j*COLS + COLS-1] = (int) FXS * -10.0;
  }

  // eta and etan
  for (j=0; j<= ROWS-1; j++) {
    for (k=0; k<=COLS-1; k++) {
      eta [j*COLS + k] = -MIN(0, hzero[j*COLS + k] );
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
  *(eta+ XMID*COLS + YMID) = (int) FXS * 1.0;

*/
 printf("Host arrays initialized.\n");

 //fclose(fdebug);  
}


//------------------------------------------
// shapiro() - filter
//------------------------------------------
void shapiro  ( host_t *wet 
              , host_t *etan
              , host_t eps
              , host_t *eta
              ) {

  //locals
  int j,k;
  host_t term1,term2,term3;

  
  //1-order Shapiro filter
  for (j=1; j<= ROWS-2; j++) {
    for (k=1; k<= COLS-2; k++) {   
        if (wet[j*COLS + k]==1) {
        term1 = ( 1+4*eps  //add swapped for substraction as tybec does not allow first operand to be constant
                  * ( wet[    j*COLS + k+1] 
                    + wet[    j*COLS + k-1] 
                    + wet[(j+1)*COLS + k  ] 
                    + wet[(j-1)*COLS + k  ] 
                    ) 
                )
                * etan[j*COLS + k]; 
        term2 = 4*eps
                * ( wet [j*COLS + k+1]
                  * etan[j*COLS + k+1]
                  + wet [j*COLS + k-1]
                  * etan[j*COLS + k-1]
                  );
        term3 = 4*eps
                * ( wet [(j+1)*COLS + k]
                  * etan[(j+1)*COLS + k]
                  + wet [(j-1)*COLS + k]
                  * etan[(j-1)*COLS + k]
                  );
        eta[j*COLS + k] = term1 + term2 + term3;
      }//if
      else {
        eta[j*COLS + k] = etan[j*COLS + k];
      }//else
    }//for
  }//for
}//()

//------------------------------------------
// oclh_log_results
//------------------------------------------
void log_results ( host_t* eta_g
){
  printf("Logging data\n");
  FILE * feta_g;
  FILE * fp_verify;
  FILE * fp_verify_hex;

  feta_g    = fopen ("eta_g.dat"  ,"w");
  fp_verify     = fopen("verifyC.dat", "w");    //used for verification in verilog TB
  fp_verify_hex = fopen("verifyChex.dat", "w"); //used for verification in verilog TB

  //general logging
  for (int i = 0; i < ROWS; ++i) {
    for (int j = 0; j < COLS; ++j) {
      fprintf(feta_g  ,"%d,  ", *(eta_g   + i*COLS + j));
    }//j
    fprintf(feta_g  ,"\n");
  }//i
  
  //logging for HDL verification
  //choosing un for verification
	for (int lin=0;lin<SIZE;lin++){ 
    fprintf (fp_verify	, "%d = %d\n", lin, eta_g[lin]);
	  fprintf (fp_verify_hex, "%x\n", eta_g[lin]);    
  }
	printf("Results logged\n");
  
  fclose(feta_g  );  
  fclose(fp_verify);
  fclose(fp_verify_hex);
}//()