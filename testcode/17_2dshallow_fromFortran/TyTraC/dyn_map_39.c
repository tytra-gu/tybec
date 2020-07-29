#include <math.h>
void dyn_map_39(float dt,float g,float eta_j_k,float eta_j_kp1,float eta_jp1_k,float dx,float dy,float u_j_k,float *du_j_k,int wet_j_k,int wet_j_kp1,int wet_jp1_k,float *duu,float v_j_k,float *dv_j_k,float *un_j_k,float *un_j_km1,float h_j_k,float h_j_km1,float h_j_kp1,float h_jm1_k,float h_jp1_k,float *vn_j_k,float *vn_jm1_k,float *etan_j_k) {

        // local vars: j,k,uu,vv,dvv,hep,hen,hue,hwp,hwn,huw,hnp,hnn,hvn,hsp,hsn,hvs
    float uu;
    float vv;
    float dvv;
    float hep;
    float hen;
    float hue;
    float hwp;
    float hwn;
    float huw;
    float hnp;
    float hnn;
    float hvn;
    float hsp;
    float hsn;
    float hvs;
        // parallelfortran: synthesised loop variable decls
    // READ
    // WRITTEN
    // READ & WRITTEN
    // globalIdDeclaration
    // globalIdInitialisation
    // ptrAssignments_fseq
        // parallelfortran: synthesised loop variables
        // parallelfortran: original code
    *du_j_k = -dt*g*(eta_j_kp1-eta_j_k)/dx;
    *dv_j_k = -dt*g*(eta_jp1_k-eta_j_k)/dy;
    *un_j_k = 0.0;
    uu = u_j_k;
    *duu = *du_j_k;
  if (wet_j_k==1) {
  if ((wet_j_kp1==1)||((*duu)>0.0))    *un_j_k = uu+(*duu);
   } else {
  if ((wet_j_kp1==1)&&((*duu)<0.0))    *un_j_k = uu+(*duu);
  }
    vv = v_j_k;
    dvv = *dv_j_k;
    *vn_j_k = 0.0;
  if (wet_j_k==1) {
  if ((wet_jp1_k==1)||((*dv_j_k)>0.0))    *vn_j_k = vv+dvv;
   } else {
  if ((wet_jp1_k==1)&&((*dv_j_k)<0.0))    *vn_j_k = vv+dvv;
  }
    hep = 0.5*((*un_j_k)+(float)fabs((*un_j_k)))*h_j_k;
    hen = 0.5*((*un_j_k)-(float)fabs((*un_j_k)))*h_j_kp1;
    hue = hep+hen;
    hwp = 0.5*((*un_j_km1)+(float)fabs((*un_j_km1)))*h_j_km1;
    hwn = 0.5*((*un_j_km1)-(float)fabs((*un_j_km1)))*h_j_k;
    huw = hwp+hwn;
    hnp = 0.5*((*vn_j_k)+(float)fabs((*vn_j_k)))*h_j_k;
    hnn = 0.5*((*vn_j_k)-(float)fabs((*vn_j_k)))*h_jp1_k;
    hvn = hnp+hnn;
    hsp = 0.5*((*vn_jm1_k)+(float)fabs((*vn_jm1_k)))*h_jm1_k;
    hsn = 0.5*((*vn_jm1_k)-(float)fabs((*vn_jm1_k)))*h_j_k;
    hvs = hsp+hsn;
    *etan_j_k = eta_j_k-dt*(hue-huw)/dx-dt*(hvn-hvs)/dy;
  }
  
