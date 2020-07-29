#include <math.h>
void shapiro_reduce_19(float etan_j_k,float *etan_avg) {

          const int nx = 500;
          const int ny = 500;
        // local vars: j,k
        // parallelfortran: synthesised loop variable decls
    // READ
    // WRITTEN
    // READ & WRITTEN
    // ptrAssignments_fseq
        // parallelfortran: synthesised loop variables
        // parallelfortran: original code
        *etan_avg = (*etan_avg)+etan_j_k/(nx*ny);
        //*etan_avg = (etan_j_k)+etan_j_k/(nx*ny);
    
    }
    
