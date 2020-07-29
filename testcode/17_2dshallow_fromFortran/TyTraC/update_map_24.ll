define void @update_map_24(float %hzero_j_k, float %eta_j_k, float* %h_j_k, float %hmin, float %un_j_k, float %vn_j_k, i32* %wet_j_k, float* %u_j_k, float* %v_j_k) {
  %1 = fadd float %hzero_j_k, %eta_j_k 
  store float %1, float* %h_j_k, align 4
  store i32 1, i32* %wet_j_k, align 4
  %2 = load float, float* %h_j_k, align 4 
  %3 = fcmp olt float %2, %hmin 
  br i1 %3, label %4, label %5

; <label>:4:                                     ; preds = %0
  store i32 0, i32* %wet_j_k, align 4
  br label %5

; <label>:5:                                     ; preds = %4, %0
  store float %un_j_k, float* %u_j_k, align 4
  store float %vn_j_k, float* %v_j_k, align 4
  ret void
}
