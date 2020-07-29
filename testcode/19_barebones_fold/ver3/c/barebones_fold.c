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
#define SIZE	        4
  //size of full streams
#define SIZE_REDUCED  1
  //size of reduced "streams"
  
//#define SIZE		1024*1024
//#define SIZE		512*512
#define NSTEP	  1

//Floats?
//#define FLOATD

#ifndef FLOAT
  //this is default
  #define INTD
#endif

#ifdef FLOATD
typedef float data_t;
#else
typedef int data_t;
#endif

//deffine this if you want to write results to file (for use in RTL verification e.g.)
//dont use for very large sizes
#define LOGRESULTS

//-------------------------------------------------
//signatures
//-------------------------------------------------
void init	  (data_t[]	 ,data_t[]	);
void kernel_A (data_t[]	 ,data_t[]	,data_t[]);
void kernel_B (data_t[]	 ,data_t[]	);
void kernel_C (data_t[]	 ,data_t[]	);
void kernel_D (data_t[]	 ,data_t[] ,data_t[]	);
void computeKernelFunction(data_t[], data_t[], data_t[]);

void post	  (FILE*  ,FILE*  ,FILE*  ,data_t[]	 ,data_t[]	,data_t[]  ,data_t[]  ,data_t[]	 ,data_t[]);

//-------------------------------------------------
//measuring time
//-------------------------------------------------
#include <time.h>
clock_t start, end;
double cpu_time_used;
time_t  start_time, end_time;

//-------------------------------------------------
//main()
//-------------------------------------------------
int main(void) {
  //constants
  
  //IOs
  data_t* vin0;//[SIZE];
  data_t* vin1;//[SIZE];
  data_t* vout;//[SIZE]={0}; //redundant
  //data_t sout; //folded scalar output
 
  vin0 = (data_t *)malloc(sizeof(data_t)*SIZE);
  vin1 = (data_t *)malloc(sizeof(data_t)*SIZE);
  vout = (data_t *)malloc(sizeof(data_t)*SIZE);
  

  //internal variables
  data_t* vconn_A_to_BC;
  data_t* vconn_B_to_D_folded;
  data_t* vconn_C_to_D;
  vconn_A_to_BC = (data_t *)malloc(sizeof(data_t)*SIZE);
  vconn_B_to_D_folded = (data_t *)malloc(sizeof(data_t)*SIZE_REDUCED);
  vconn_C_to_D = (data_t *)malloc(sizeof(data_t)*SIZE);

  //initialize variables
  init(vin0, vin1);
  
  //initialize output file
  FILE *fp, *fp_verify, *fp_verify_hex;
  fp = fopen("out.csv", "w");
  fp_verify = fopen("verifyC.dat", "w");
  fp_verify_hex = fopen("verifyChex.dat", "w");
  
  start = clock();	
  //time (&start_time);

  //kernels are called repeatedly, .e.g in a time loop
//#pragma TRANSFER_2_DEVICE vin0	
//#pragma TRANSFER_2_DEVICE vin1

  for (int step=0; step<NSTEP; step++) {
//#pragma DEVICE_CODE_START
	  kernel_A	( vin0
				, vin1
				, vconn_A_to_BC
				);	
				   
	  kernel_B (  vconn_A_to_BC
              , vconn_B_to_D_folded //reduced (scalar) output
              );

    kernel_C  ( vconn_A_to_BC
              , vconn_C_to_D //map (full) output
              );
					 
	  kernel_D  ( vconn_B_to_D_folded //reduced (scalar) input
              , vconn_C_to_D //full stream input
              , vout
              );
					

//#pragma DEVICE_CODE_END
  //#pragma TRANSFER_FROM_DEVICE vout
  }//for NSTEP (time-loop)
  
  end = clock();
  //time (&end_time);
  //double dif = difftime (end_time,start_time);
	cpu_time_used = (double)((double) (end - start)) / CLOCKS_PER_SEC;
	printf("Kernel execution took %f seconds (using clock_t)\n", cpu_time_used);
	//printf("Kernel execution took %f seconds (using time_t)\n", dif);

post  ( fp
	  , fp_verify
	  , fp_verify_hex
	  , vin0
	  , vin1
	  , vconn_A_to_BC
	  , vconn_B_to_D_folded
	  , vconn_C_to_D
	  , vout
	  );
  return 0;
}//main()

//-------------------------------------------------
//init()
//-------------------------------------------------
void init(data_t vin0[], data_t vin1[]) {
	//init vectors
	for(int i=0; i<SIZE; i++) {
	  //random int between 0 and MAXINPUT
	  //vin0[i] = rand() % MAXINPUT;
	  //vin1[i] = rand() % MAXINPUT;
	  //simple pattern of numbers
	  vin0[i] = i+1;
	  vin1[i] = i+1;
	  //vin1[i] = SIZE+i;
	}
}

//--------------------------------------
//- kernel_A
//--------------------------------------

//-----------------
void kernel_A ( data_t vin0[]
              , data_t vin1[]
              , data_t vout[]
              ) {
  for (int i=0; i<SIZE; i++) {
	  data_t local1 = vin0[i] + vin1[i];
	  data_t local2 = vin0[i] + vin1[i];
	  data_t local3 = local1 + local2;
    
    //final: buffer will have 2 taps
	  data_t local4 = local1 + local3;
	  vout[i] = local1 + local4;
  }//for
}//() 

//--------------------------------------
//- kernel_B
//--------------------------------------
void kernel_B ( data_t vin[]
              , data_t vout[]
              ) {
  vout[0] = 0; 
  for (int i=0; i<SIZE; i++) {
    vout[0] = vin[i] + vout[0];
  }//for
}//() 

//--------------------------------------
//- kernel_C
//--------------------------------------
void kernel_C ( data_t vin[]
              , data_t vout[]
              ) {
  for (int i=0; i<SIZE; i++) {
    vout[i] = vin[i] + vin[i];
  }//for
}//() 

//--------------------------------------
//- kernel_D
//--------------------------------------
void kernel_D ( data_t vinF[] //input from fold node, reduced stream
              , data_t vinM[] //input from map node, full stream
              , data_t vout[]
              ) {
  for (int i=0; i<SIZE; i++) {
    vout[i] = vinM[i] + vinF[0];
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
		  , data_t vconn_A_to_BC[]
		  , data_t vconn_B_to_D_folded[]
		  , data_t vconn_C_to_D[]
		  , data_t vout[]
		  ) {
#ifdef LOGRESULTS
	//log results for use in verification of OCL/HDL code	   
	//fprintf(fp, "-------------------------------------------------------------------------------------------------------------------------------------------\n");
	fprintf(fp, "		   i,	   vin0(i),	   vin1(i),		  vconn_A_to_BC(i),	 vconn_B_to_D_folded(0),	vconn_C_to_D(i),	vout	   \n");
	//fprintf(fp, "-------------------------------------------------------------------------------------------------------------------------------------------\n");
	for (int i=0;i<SIZE;i++){ 
	  //pretty print for human
#ifdef FLOATD	   
	  fprintf (fp, "\t%d,\t%f,\t%f,\t%f,\t%f,\t%f,\t%f\n"
#else	   
	  fprintf (fp, "\t%d,\t%d,\t%d,\t%d,\t%d,\t%d,\t%d\n"
#endif	  
				 , i,  vin0[i],	 vin1[i], vconn_A_to_BC[i],	vconn_B_to_D_folded[0],   vconn_C_to_D[i],	 vout[i]);
				 
	  //boring print for machine (hex and decimal)
#ifdef FLOATD	   
	  fprintf (fp_verify	, "%d = %f\n", i, vout[i]);
#else	   
	  fprintf (fp_verify	, "%d = %d\n", i, vout[i]);
#endif	  
	  fprintf (fp_verify_hex, "%x\n", vout[i]);
	}
	printf("Results logged\n");

#endif
  //#ifdef LOGRESULTS
}