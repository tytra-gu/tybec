#include <math.h>
void shapiro_dyn_update_superkernel(float *etan,float *global_etan_avg_array,int *wet,float *eps,float *eta,float *etan_avg,float *dt,float *g,float *dx,float *dy,float *u,float *du,float *duu,float *v,float *dv,float *un,float *h,float *vn,float *hzero,float *hmin,int *state_ptr) {

    int global_id;
    int j;
    int j_rel;
    int k;
    int k_range;
    int k_rel;
  int state;
  const int st_shapiro_reduce_19 = 0;
  const int st_shapiro_map_24 = 1;
  const int st_dyn_map_39 = 2;
  float h_j_km1;
  float dv_j_k;
  int wet_jm1_k;
  float eta_j_kp1;
  float h_j_kp1;
  int wet_jp1_k;
  float etan_jm1_k;
  float eta_j_k;
  float du_j_k;
  float vn_j_k;
  float u_j_k;
  float v_j_k;
  float un_j_k;
  int wet_j_km1;
  float h_jm1_k;
  float etan_jp1_k;
  float vn_jm1_k;
  float etan_j_km1;
  float h_jp1_k;
  float hzero_j_k;
  float etan_j_kp1;
  float h_j_k;
  float un_j_km1;
  float eta_jp1_k;
  float etan_j_k;
  int wet_j_k;
  int wet_j_kp1;
  const int st_update_map_24 = 3;
    state = *state_ptr;
  // SUPERKERNEL BODY
  switch ( state ) {
        case (st_shapiro_reduce_19): {
            etan_j_k = etan[F2D2C((((ny+1) - 0 )+1) , 0,0 , j,k)];
            shapiro_reduce_19(etan_j_k,(*global_etan_avg_array));
        } break;
        case (st_shapiro_map_24): {
        global_id = get_global_id(0);
        k_range = ((500-1)+1);
        j_rel = global_id/k_range;
        j = j_rel+1;
        k_rel = (global_id-(j_rel*k_range));
        k = k_rel+1;
            eta_j_k = eta[F2D2C((((ny+1) - 0 )+1) , 0,0 , j,k)];
            etan_j_k = etan[F2D2C((((ny+1) - 0 )+1) , 0,0 , j,k)];
            etan_j_km1 = etan[F2D2C((((ny+1) - 0 )+1) , 0,0 , j,k-1)];
            etan_j_kp1 = etan[F2D2C((((ny+1) - 0 )+1) , 0,0 , j,k+1)];
            etan_jm1_k = etan[F2D2C((((ny+1) - 0 )+1) , 0,0 , j-1,k)];
            etan_jp1_k = etan[F2D2C((((ny+1) - 0 )+1) , 0,0 , j+1,k)];
            wet_j_k = wet[F2D2C((((ny+1) - 0 )+1) , 0,0 , j,k)];
            wet_j_km1 = wet[F2D2C((((ny+1) - 0 )+1) , 0,0 , j,k-1)];
            wet_j_kp1 = wet[F2D2C((((ny+1) - 0 )+1) , 0,0 , j,k+1)];
            wet_jm1_k = wet[F2D2C((((ny+1) - 0 )+1) , 0,0 , j-1,k)];
            wet_jp1_k = wet[F2D2C((((ny+1) - 0 )+1) , 0,0 , j+1,k)];
            shapiro_map_24(wet_j_k,wet_j_km1,wet_j_kp1,wet_jm1_k,wet_jp1_k,(*eps),etan_j_k,etan_j_km1,etan_j_kp1,etan_jm1_k,etan_jp1_k,eta_j_k,(*etan_avg));
            eta[F2D2C((((ny+1) - 0 )+1) , 0,0 , j,k)] = eta_j_k;
        } break;
        case (st_dyn_map_39): {
        global_id = get_global_id(0);
        k_range = ((500-1)+1);
        j_rel = global_id/k_range;
        j = j_rel+1;
        k_rel = (global_id-(j_rel*k_range));
        k = k_rel+1;
            du_j_k = du[F2D2C((((ny+1) - 0 )+1) , 0,0 , j,k)];
            dv_j_k = dv[F2D2C((((ny+1) - 0 )+1) , 0,0 , j,k)];
            eta_j_k = eta[F2D2C((((ny+1) - 0 )+1) , 0,0 , j,k)];
            eta_j_kp1 = eta[F2D2C((((ny+1) - 0 )+1) , 0,0 , j,k+1)];
            eta_jp1_k = eta[F2D2C((((ny+1) - 0 )+1) , 0,0 , j+1,k)];
            h_j_k = h[F2D2C((((ny+1) - 0 )+1) , 0,0 , j,k)];
            h_j_km1 = h[F2D2C((((ny+1) - 0 )+1) , 0,0 , j,k-1)];
            h_j_kp1 = h[F2D2C((((ny+1) - 0 )+1) , 0,0 , j,k+1)];
            h_jm1_k = h[F2D2C((((ny+1) - 0 )+1) , 0,0 , j-1,k)];
            h_jp1_k = h[F2D2C((((ny+1) - 0 )+1) , 0,0 , j+1,k)];
            u_j_k = u[F2D2C((((ny+1) - 0 )+1) , 0,0 , j,k)];
            un_j_k = un[F2D2C((((ny+1) - 0 )+1) , 0,0 , j,k)];
            un_j_km1 = un[F2D2C((((ny+1) - 0 )+1) , 0,0 , j,k-1)];
            v_j_k = v[F2D2C((((ny+1) - 0 )+1) , 0,0 , j,k)];
            vn_j_k = vn[F2D2C((((ny+1) - 0 )+1) , 0,0 , j,k)];
            vn_jm1_k = vn[F2D2C((((ny+1) - 0 )+1) , 0,0 , j-1,k)];
            wet_j_k = wet[F2D2C((((ny+1) - 0 )+1) , 0,0 , j,k)];
            wet_j_kp1 = wet[F2D2C((((ny+1) - 0 )+1) , 0,0 , j,k+1)];
            wet_jp1_k = wet[F2D2C((((ny+1) - 0 )+1) , 0,0 , j+1,k)];
            dyn_map_39((*dt),(*g),eta_j_k,eta_j_kp1,eta_jp1_k,(*dx),(*dy),u_j_k,du_j_k,wet_j_k,wet_j_kp1,wet_jp1_k,(*duu),v_j_k,dv_j_k,un_j_k,un_j_km1,h_j_k,h_j_km1,h_j_kp1,h_jm1_k,h_jp1_k,vn_j_k,vn_jm1_k,etan_j_k);
            du[F2D2C((((ny+1) - 0 )+1) , 0,0 , j,k)] = du_j_k;
            dv[F2D2C((((ny+1) - 0 )+1) , 0,0 , j,k)] = dv_j_k;
            etan[F2D2C((((ny+1) - 0 )+1) , 0,0 , j,k)] = etan_j_k;
            un[F2D2C((((ny+1) - 0 )+1) , 0,0 , j,k)] = un_j_k;
            un[F2D2C((((ny+1) - 0 )+1) , 0,0 , j,k-1)] = un_j_km1;
            vn[F2D2C((((ny+1) - 0 )+1) , 0,0 , j,k)] = vn_j_k;
            vn[F2D2C((((ny+1) - 0 )+1) , 0,0 , j-1,k)] = vn_jm1_k;
        } break;
        case (st_update_map_24): {
        global_id = get_global_id(0);
        k_range = (((500+1)-0)+1);
        j_rel = global_id/k_range;
        j = j_rel+0;
        k_rel = (global_id-(j_rel*k_range));
        k = k_rel+0;
            eta_j_k = eta[F2D2C((((ny+1) - 0 )+1) , 0,0 , j,k)];
            h_j_k = h[F2D2C((((ny+1) - 0 )+1) , 0,0 , j,k)];
            hzero_j_k = hzero[F2D2C((((ny+1) - 0 )+1) , 0,0 , j,k)];
            un_j_k = un[F2D2C((((ny+1) - 0 )+1) , 0,0 , j,k)];
            vn_j_k = vn[F2D2C((((ny+1) - 0 )+1) , 0,0 , j,k)];
            update_map_24(hzero_j_k,eta_j_k,h_j_k,(*hmin),un_j_k,vn_j_k,wet_j_k,u_j_k,v_j_k);
            h[F2D2C((((ny+1) - 0 )+1) , 0,0 , j,k)] = h_j_k;
            u[F2D2C((((ny+1) - 0 )+1) , 0,0 , j,k)] = u_j_k;
            v[F2D2C((((ny+1) - 0 )+1) , 0,0 , j,k)] = v_j_k;
            wet[F2D2C((((ny+1) - 0 )+1) , 0,0 , j,k)] = wet_j_k;
      }
  }
  }
  
