#define NTOT 1
#define data_t int
#define ROWS  1024 
#define COLS  1024 

// -------------------------------
// ABS
// -------------------------------

//integer
//#define ABS abs

//float
#define ABS fabs

//CONSTANTS 
//int
#define CONST1 5
#define CONST2 1
#define CONST3 4

//float
//#define CONST1 0.5
//#define CONST2 1.0
//#define CONST3 0.25

// -------------------------------
// SUB-KERNEL SIGNATURES
// -------------------------------
void kernel_dyn( const data_t dt
               , const data_t dx
               , const data_t dy
               , const data_t g
               , __global data_t * restrict eta
               , __global data_t * restrict un
               , __global data_t * restrict u
               , __global data_t * restrict wet
               , __global data_t * restrict v
               , __global data_t * restrict vn
               , __global data_t * restrict h
               , __global data_t * restrict etan
               );

void kernel_shapiro  ( const data_t eps 
                     , __global data_t * restrict etan
                     , __global data_t * restrict wet 
                     , __global data_t * restrict eta
                     );

void kernel_updates ( __global data_t * restrict h 
                    , __global data_t * restrict hzero
                    , __global data_t * restrict eta
                    , __global data_t * restrict u
                    , __global data_t * restrict un
                    , __global data_t * restrict v
                    , __global data_t * restrict vn
                    , __global data_t * restrict wet
                    , data_t hmin
                    );

// -------------------------------
// SUPER KERNEL
// -------------------------------

__kernel void Kernel( const data_t dt
                    , const data_t dx
                    , const data_t dy
                    , const data_t g
                    , const data_t eps
                    , const data_t hmin
                    , __global data_t * restrict eta
                    , __global data_t * restrict un
                    , __global data_t * restrict u
                    , __global data_t * restrict wet
                    , __global data_t * restrict v
                    , __global data_t * restrict vn
                    , __global data_t * restrict h
                    , __global data_t * restrict etan
                    , __global data_t * restrict hzero
                    ) {
//If we want time-loop on device, then uncomment loop (and remove time loop on host)                      
//for (int i=0;i<NTOT;i++) {
kernel_dyn( dt
          , dx
          , dy
          , g
          , eta
          , un
          , u
          , wet
          , v
          , vn
          , h
          , etan
          );

kernel_shapiro  ( eps 
                , etan
                , wet 
                , eta
                );

kernel_updates ( h 
               , hzero
               , eta
               , u
               , un
               , v
               , vn
               , wet
               , hmin
               );
//}//for
}//()

// -------------------------------
// DYN KERNEL
// -------------------------------
void kernel_dyn( const data_t dt
               , const data_t dx
               , const data_t dy
               , const data_t g
               , __global data_t * restrict eta
               , __global data_t * restrict un
               , __global data_t * restrict u
               , __global data_t * restrict wet
               , __global data_t * restrict v
               , __global data_t * restrict vn
               , __global data_t * restrict h
               , __global data_t * restrict etan
               ) {

 //locals
//-------------------
//__local data_t du[ROWS][COLS];
//__local data_t dv[ROWS][COLS];
//posix_memalign ((void**)&du, ALIGNMENT, SIZE*BytesPerWord);
//posix_memalign ((void**)&dv, ALIGNMENT, SIZE*BytesPerWord);
data_t du;
data_t dv;
data_t uu;
data_t vv;
data_t duu;
data_t dvv;
data_t hue;
data_t huw;
data_t hwp;
data_t hwn;
data_t hen;
data_t hep;
data_t hvn;
data_t hvs;
data_t hsp;
data_t hsn;
data_t hnn;
data_t hnp;
int j, k;


//loops for du, dv merged with loops for u and v
//that is why we no longer need local arrays du[] and dv[] for intermediat results (of duu and dvv)
//we just use duu and dvv directly as connecting scalars in this merged loops
  for (j=1; j<= ROWS-2; j++) {
    for (k=1; k<= COLS-2; k++) {
      //*(du + j*COLS + k)  = -dt 
      //du[j][k]  = -dt 
//calculate du, dv on all non-boundary points
//-------------------------------------------
      duu  = -dt 
           * g
           * ( eta[j*COLS + k+1]
             - eta[j*COLS + k  ]
             ) 
           / dx;
      //*(dv + j*COLS + k)  = -dt 
      //dv[j][k]  = -dt 
      dvv  = -dt 
           * g
           * ( eta[(j+1)*COLS + k]
             - eta[    j*COLS + k]
             ) 
           / dy;

//prediction for u and v (merged loop)
//---------------------------------
      un[j*COLS + k]  = 0;//0.0;
      uu = u[j*COLS + k];
      //printf("I am OUT here\n");
      if (  ( (wet[j*COLS + k] == 1)
              && ( (wet[j*COLS + k+1] == 1) || (duu > 0)))
         || ( (wet[j*COLS + k+1] == 1) && (duu < 0))     
         ){
          un[j*COLS + k] = uu+duu;
          //printf("I am IN here\n");
      }//if
      
      vn[j*COLS + k]  = 0;//0.0;
      vv = v[j*COLS + k];
      if (  (  (wet[j*COLS + k] == 1)
             && ( (wet[(j+1)*COLS + k] == 1) || (dvv > 0)))
         || ((wet[(j+1)*COLS + k] == 1) && (dvv < 0))     
         ){
          vn[j*COLS + k] = vv+dvv;
      }//if
     //printf("Inside kernel, j = %d, k = %d, eta = %f,wet = %f, un = %d, vn = %d\n",j, k, eta[j*COLS + k],wet[j*COLS + k], un[j*COLS + k], vn[j*COLS + k]);

    }//for
  }//for

//sea level predictor
//--------------------
//TODO: Can I merge this loop? Note the use of stencil.. if I merge, then I will get stale values?
  for (j=1; j<= ROWS-2; j++) {
    for (k=1; k<= COLS-2; k++) {   
      hep = CONST1*( un[j*COLS + k] + ABS(un[j*COLS + k]) ) * h[j*COLS + k  ];
      hen = CONST1*( un[j*COLS + k] - ABS(un[j*COLS + k]) ) * h[j*COLS + k+1];
      hue = hep+hen;

      hwp = CONST1*( un[j*COLS + k-1] + ABS(un[j*COLS + k-1]) ) * h[j*COLS + k-1];
      hwn = CONST1*( un[j*COLS + k-1] - ABS(un[j*COLS + k-1]) ) * h[j*COLS + k  ];
      huw = hwp+hwn;

      hnp = CONST1*( vn[j*COLS + k] + ABS(vn[j*COLS + k]) ) * h[    j*COLS + k];
      hnn = CONST1*( vn[j*COLS + k] - ABS(vn[j*COLS + k]) ) * h[(j+1)*COLS + k];
      hvn = hnp+hnn;

      hsp = CONST1*( vn[(j-1)*COLS + k] + ABS(vn[(j-1)*COLS + k]) ) * h[(j-1)*COLS + k];
      hsn = CONST1*( vn[(j-1)*COLS + k] - ABS(vn[(j-1)*COLS + k]) ) * h[    j*COLS + k];
      hvs = hsp+hsn;

      etan[j*COLS + k]  = eta[j*COLS + k]
                        - dt*(hue-huw)/dx
                        - dt*(hvn-hvs)/dy;
    }//for
  }//for  

}//()



//------------------------------------------
// SHAPIRO KERNEL
//------------------------------------------
void kernel_shapiro     ( const data_t eps 
                        , __global data_t * restrict etan
                        , __global data_t * restrict wet 
                        , __global data_t * restrict eta
                        ) {

  //locals
  int j,k;
  data_t term1,term2,term3;

  //1-order Shapiro filter
  for (j=1; j<= ROWS-2; j++) {
    for (k=1; k<= COLS-2; k++) {   
        if (wet[j*COLS + k]==1) {
        term1 = ( CONST2-CONST3*eps
                  * ( wet[    j*COLS + k+1] 
                    + wet[    j*COLS + k-1] 
                    + wet[(j+1)*COLS + k  ] 
                    + wet[(j-1)*COLS + k  ] 
                    ) 
                )
                * etan[j*COLS + k]; 
        term2 = CONST3*eps
                * ( wet [j*COLS + k+1]
                  * etan[j*COLS + k+1]
                  + wet [j*COLS + k-1]
                  * etan[j*COLS + k-1]
                  );
        term3 = CONST3*eps
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
// UPDATES KERNEL
//------------------------------------------
void kernel_updates ( __global data_t * restrict h 
                    , __global data_t * restrict hzero
                    , __global data_t * restrict eta
                    , __global data_t * restrict u
                    , __global data_t * restrict un
                    , __global data_t * restrict v
                    , __global data_t * restrict vn
                    , __global data_t * restrict wet
                    , data_t hmin
                    ) {

  for (int j=0; j<= ROWS-1; j++) {
    for (int k=0; k<=COLS-1; k++) {
      //h update
      h[j*COLS + k] = hzero[j*COLS + k] 
                    + eta  [j*COLS + k];
      //printf("Inside kernel, j = %d, k = %d, h = %f,eta = %f\n",j, k, h[j*COLS + k],eta[j*COLS + k]);
      //wet update
      wet[j*COLS + k] = 1;
      if ( h[j*COLS + k] < hmin )
            wet[j*COLS + k] = 0;
      //u, v updates
      u[j*COLS + k] = un[j*COLS + k];
      //u[j*COLS + k] = 7;
      v[j*COLS + k] = vn[j*COLS + k];
    }//for
  }//for
}//()
