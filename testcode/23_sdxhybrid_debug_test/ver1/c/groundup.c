//*****************************************!
// A simple synthetic example
// for debugging ocl-hdl integration
//
// Author: S Waqar Nabi
//
// Created: 2019.12.20
//
// Modifications:
//
//*****************************************!

#include <stdio.h>
#include <stdlib.h>

//CONSTANTS
#define IM      32
#define JM      IM
#define SIZE	  (IM*JM)
#define NSTEP	  1
typedef int data_t;

//-------------------------------------------------
//signatures
//-------------------------------------------------
void init	  (data_t[]	 ,data_t[]	);
void kernel_A (data_t[]	 ,data_t[]	,data_t[]);
void kernel_B (data_t[]	 ,data_t[]	);
void kernel_C (data_t[]	 ,data_t[]	);
void kernel_D (data_t[]	 ,data_t[]	);
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
  data_t* vin0; //[SIZE];
  data_t* vin1; //[SIZE];
  data_t* vout; //[SIZE]={0};
 
  vin0 = (data_t *)malloc(sizeof(data_t)*SIZE);
  vin1 = (data_t *)malloc(sizeof(data_t)*SIZE);
  vout = (data_t *)malloc(sizeof(data_t)*SIZE);

  //internal variables
  data_t* vconn_A_to_B;
  data_t* vconn_B_to_C;
  data_t* vconn_C_to_D;
  vconn_A_to_B = (data_t *)malloc(sizeof(data_t)*SIZE);
  vconn_B_to_C = (data_t *)malloc(sizeof(data_t)*SIZE);
  vconn_C_to_D = (data_t *)malloc(sizeof(data_t)*SIZE);

  //initialize variables
  init(vin0, vin1);
  
  //initialize output file
  FILE *fp, *fp_verify, *fp_verify_hex;
  fp = fopen("out.csv", "w");
  fp_verify = fopen("verifyC.dat", "w");
  fp_verify_hex = fopen("verifyChex.dat", "w");
  
  start = clock();	
  for (int step=0; step<NSTEP; step++) {
	  kernel_A	( vin0
				, vin1
				, vconn_A_to_B
				);	
				   
	  kernel_B ( vconn_A_to_B
			   , vconn_B_to_C
			   );
					 
	  kernel_C ( vconn_B_to_C
			   , vconn_C_to_D
			   );
					
	  kernel_D ( vconn_C_to_D
			   , vout
			   );
  }//for NSTEP (time-loop)
  
  end = clock();
	cpu_time_used = (double)((double) (end - start)) / CLOCKS_PER_SEC;
	printf("Kernel execution took %f seconds (using clock_t)\n", cpu_time_used);

post  ( fp
	  , fp_verify
	  , fp_verify_hex
	  , vin0
	  , vin1
	  , vconn_A_to_B
	  , vconn_B_to_C
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

void kernel_A ( data_t vin0[]
              , data_t vin1[]
              , data_t vconn_A_to_B[]
              ) {
  for (int i=0; i<SIZE; i++) {
	  data_t local1 = vin0[i] + vin1[i];
	  data_t local2 = vin0[i] + vin1[i];
	  data_t local3 = local1 - local2;
    
    //interim: buffer has 1 tap
	  //vconn_A_to_B[i] = local1 + local3;
    //printf("i = %d, vconn_A_to_B[i] = %d\n", i, vconn_A_to_B[i]);
    
    //final: buffer will have 2 taps
	  data_t local4 = local1 + local3;
	  vconn_A_to_B[i] = local1 + local4;
  }//for
}//() 


//--------------------------------------
//- kernel_B
//--------------------------------------
void kernel_B ( data_t vconn_A_to_B[]
			  , data_t vconn_B_to_C[]
			  ) {
  for (int i=0; i<SIZE; i++) {
	vconn_B_to_C[i] = vconn_A_to_B[i] + vconn_A_to_B[i];
  }//for
}//() 

//--------------------------------------
//- kernel_C
//--------------------------------------
void kernel_C ( data_t vconn_B_to_C[]
			  , data_t vconn_C_to_D[]
			  ) {
  for (int i=0; i<SIZE; i++) {
	vconn_C_to_D[i] = vconn_B_to_C[i] * vconn_B_to_C[i];
  }//for
}//() 

//--------------------------------------
//- kernel_D
//--------------------------------------
void kernel_D ( data_t vconn_C_to_D[]
			  , data_t vout[]
			  ) {
  for (int i=0; i<SIZE; i++) {
	vout[i] = vconn_C_to_D[i] + vconn_C_to_D[i];
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
		  , data_t vconn_A_to_B[]
		  , data_t vconn_B_to_C[]
		  , data_t vconn_C_to_D[]
		  , data_t vout[]
		  ) {

	//log results for use in verification of OCL/HDL code	   
	fprintf(fp, "-------------------------------------------------------------------------------------------------------------------------------------------\n");
	fprintf(fp, "		   i,	   vin0(i),	   vin1(i),		  vcon`n_A_to_B(i),	 vconn_B_to_C(i),	vconn_C_to_D(i),	vout(i)	   \n");
	fprintf(fp, "-------------------------------------------------------------------------------------------------------------------------------------------\n");
	for (int i=0;i<SIZE;i++){ 
	  //pretty print for human
	  fprintf (fp, "\t%d,\t%d,\t%d,\t%d,\t%d,\t%d,\t%d\n"
				 , i,  vin0[i],	 vin1[i], vconn_A_to_B[i],	vconn_B_to_C[i],   vconn_C_to_D[i],	 vout[i]);				 
	  fprintf (fp_verify	, "%d = %d\n", i, vout[i]);
	  fprintf (fp_verify_hex, "%x\n", vout[i]);
	}
	printf("Results logged\n");
}