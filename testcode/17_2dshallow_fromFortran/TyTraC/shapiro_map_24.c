#include <math.h>
void shapiro_map_24(int wet_j_k,int wet_j_km1,int wet_j_kp1,int wet_jm1_k,int wet_jp1_k,float eps,float etan_j_k,float etan_j_km1,float etan_j_kp1,float etan_jm1_k,float etan_jp1_k,float *eta_j_k,float etan_avg) {

          const float alpha = 1e-9;
        // local vars: j,k,term1,term2,term3
    float term1;
    float term2;
    float term3;
        // parallelfortran: synthesised loop variable decls
    // READ
    // WRITTEN
    // READ & WRITTEN
    // globalIdDeclaration
    // globalIdInitialisation
    // ptrAssignments_fseq
        // parallelfortran: synthesised loop variables
        // parallelfortran: original code
    if (wet_j_k==1) {
    term1 = (1.0-0.25*eps*(wet_j_kp1+wet_j_km1+wet_jp1_k+wet_jm1_k))*etan_j_k;
    term2 = 0.25*eps*(wet_j_kp1*etan_j_kp1+wet_j_km1*etan_j_km1);
    term3 = 0.25*eps*(wet_jp1_k*etan_jp1_k+wet_jm1_k*etan_jm1_k);
    *eta_j_k = term1+term2+term3;
   } else {
    *eta_j_k = etan_j_k;
  }
    *eta_j_k = (1-alpha)*(*eta_j_k)+alpha*etan_avg;
  }
  
