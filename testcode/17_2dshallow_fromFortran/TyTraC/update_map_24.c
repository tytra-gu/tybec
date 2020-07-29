#include <math.h>
void update_map_24(float hzero_j_k,float eta_j_k,float *h_j_k,float hmin,float un_j_k,float vn_j_k,int *wet_j_k,float *u_j_k,float *v_j_k) {

        // local vars: j,k
        // parallelfortran: synthesised loop variable decls
    // READ
    // WRITTEN
    // READ & WRITTEN
    // globalIdDeclaration
    // globalIdInitialisation
    // ptrAssignments_fseq
        // parallelfortran: synthesised loop variables
        // parallelfortran: original code
    *h_j_k = hzero_j_k+eta_j_k;
    *wet_j_k = 1;
  if ((*h_j_k)<hmin)    *wet_j_k = 0;
    *u_j_k = un_j_k;
    *v_j_k = vn_j_k;
  }
  
