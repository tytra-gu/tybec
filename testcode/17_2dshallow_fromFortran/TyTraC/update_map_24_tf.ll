define void @update_map_24(float %hzero_j_k, float %eta_j_k, float* %h_j_k, float %hmin, float %un_j_k, float %vn_j_k, i32* %wet_j_k, float* %u_j_k, float* %v_j_k) {
  %r1 = fadd float %hzero_j_k, %eta_j_k 
  store float %r1, float* %h_j_k, align 4
;  store i32 1, i32* %wet_j_k, align 4
  %r2 = load float, float* %h_j_k, align 4 
  %r3 = fcmp olt float %r2, %hmin 

;  br i1 %3, label %4, label %5
; <label>:r4:                                     ; preds = %r0
;  store i32 0, i32* %wet_j_k, align 4

;  br label %5
; <label>:r5:                                     ; preds = %r4, %r0
  %not_3_1 = xor i1 %r3, true 
  %wet_j_k_store = select i1 %not_3_1, i32 1, i32 0 
  store i32 %wet_j_k_store, i32* %wet_j_k
  store float %un_j_k, float* %u_j_k, align 4
  store float %vn_j_k, float* %v_j_k, align 4
  ret void
}
