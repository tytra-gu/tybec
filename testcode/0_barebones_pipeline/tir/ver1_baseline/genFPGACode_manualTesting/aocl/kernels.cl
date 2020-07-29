#define AOCLIB

#ifdef AOCLIB
  #include "hdl_lib.h"
#endif  

typedef int device_t;

#define IN_OUT_LAT 5
#define SIZE       32

#ifndef AOCLIB
  // AOCL only function signature
device_t kernel_aocOnly(  
   global device_t * restrict vin0
  ,global device_t * restrict vin1
  ,int lincount
);  
#endif


//-----------------------------------------
// Using HDL IP
//-----------------------------------------
kernel void cl_func_lib ( 
   global device_t * restrict vin0
  ,global device_t * restrict vin1
  ,global device_t * restrict vout
  ) {

  int lincount;
  
  for (lincount = 0; lincount < (SIZE + IN_OUT_LAT); lincount++) {
    int outCount  = lincount - IN_OUT_LAT + 1;  
    
    /// input branch ///
    device_t vin0_data = vin0[lincount];
    device_t vin1_data = vin1[lincount];
  
    /// Call the kernel ///
#ifdef AOCLIB    
    device_t tempResult =  func_lib(
        vin0_data
       ,vin1_data
    );

  /// output branch ///
    if (outCount >= 0) {
      vout[outCount]=tempResult;
    } 
#else
    device_t tempResult =  kernel_aocOnly(
       vin0
      ,vin1
      ,lincount
    );
  /// output branch ///
    vout[lincount]=tempResult;
#endif    
  }//for
}

//-----------------------------------------
// OCL only
//-----------------------------------------
#ifndef AOCLIB
  device_t  kernel_aocOnly(  
     global device_t * restrict vin0
    ,global device_t * restrict vin1
    ,int i
    ){
      
   //for (int i=0; i<SIZE; i++) {
     return( (vin0[i] + vin1[i])*(vin0[i] + vin1[i])*32 );
   //}//for
}//()

#endif