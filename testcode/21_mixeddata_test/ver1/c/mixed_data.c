//*****************************************!
// A simple mock example
// for prototyping
//
// This instance is for testing
// smart buffering features
// and is based on example used
// in the HLPGPU-paper
//
// Author: S Waqar Nabi
//
// Created: 2016.12.23
//
// Modifications:
//
//*****************************************!

#include <stdio.h>
#include <stdlib.h>

//CONSTANTS
#define SIZE      16
#define NSTEP     1


typedef float data_t;




//-------------------------------------------------
//signatures
//-------------------------------------------------
void init     (data_t[]  ,data_t[]  , int[]);
void kernel_A (data_t[]  ,data_t[]  , int[], data_t[]);
void post     (FILE*  ,FILE*  ,FILE*  ,data_t[]  ,data_t[]  ,int[]  ,data_t[]);

//-------------------------------------------------
//main()
//-------------------------------------------------
int main(void) {
  //constants
  
  //IOs
  data_t vin0[SIZE];
  data_t vin1[SIZE];
  int    cond[SIZE];
  data_t vout[SIZE]={0};
 

  //initialize variables
  init(vin0, vin1, cond);
  
  //initialize output file
  FILE *fp, *fp_verify, *fp_verify_hex;
  fp = fopen("out.csv", "w");
  fp_verify = fopen("verifyC.dat", "w");
  fp_verify_hex = fopen("verifyChex.dat", "w");
  
  
  for (int i=0; i<NSTEP; i++) {
//#pragma DEVICE_CODE_START
    kernel_A  ( vin0
              , vin1
              , cond
              , vout
              );  
  }//for (time-loop)
//#pragma TRANSFER_FROM_DEVICE vout
  
post  ( fp
      , fp_verify
      , fp_verify_hex
      , vin0
      , vin1
      , cond
      , vout
      );

  return 0;
}//main()

//-------------------------------------------------
//init()
//-------------------------------------------------
void init(data_t vin0[], data_t vin1[], int cond[]) {
    //init vectors
    for(int i=0; i<SIZE; i++) {
      vin0[i] = 3.14+i+1;
      vin1[i] = 3.14+i+1;
      cond[i] = 1;
    }
    cond[10] = 0;
}

//--------------------------------------
//- kernel_A
//--------------------------------------
void kernel_A ( data_t vin0[]
              , data_t vin1[]
              , int    cond[]
              , data_t vout[]
              ) {
  for (int i=0; i<SIZE; i++) {
      data_t local1;
      
      if(cond[i])
       local1 = vin0[i] + vin1[i];
      else
       local1 = vin0[i] * vin1[i];
      
      vout[i] = local1 + local1;
  }//for
}//() 

//--------------------------
//-Writing the arrays to file
//--------------------------
void post ( FILE *fp
          , FILE *fp_verify
          , FILE *fp_verify_hex
          , data_t vin0[]
          , data_t vin1[]
          , int    cond[]
          , data_t vout[]
          ) {
            
    //log results for use in verification of OCL/HDL code      
    fprintf(fp, "-------------------------------------------------------------------------------------------------------------------------------------------\n");
    fprintf(fp, "          i,      vin0(i),    vin1(i),       cond(i),  vout(i)    \n");
    fprintf(fp, "-------------------------------------------------------------------------------------------------------------------------------------------\n");
    for (int i=0;i<SIZE;i++){ 
      //pretty print for man
      fprintf (fp, "\t%d,\t%f,\t%f,\t%d,\t%f\n"
                 , i,  vin0[i],  vin1[i], cond[i],  vout[i]);
      
      //bland print for machine
      fprintf (fp_verify    ,"%f\n", vout[i]);
      fprintf (fp_verify_hex,"%x\n", *(int*)&vout[i]);
    }
    printf("Results logged\n");
}