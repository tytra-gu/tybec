define void @shapiro_map_24(i32 %wet_j_k, i32 %wet_j_km1, i32 %wet_j_kp1, i32 %wet_jm1_k, i32 %wet_jp1_k, float %eps, float %etan_j_k, float %etan_j_km1, float %etan_j_kp1, float %etan_jm1_k, float %etan_jp1_k, float* %eta_j_k, float %etan_avg) {
  %r1 = icmp eq i32 %wet_j_k, 1 

;  br i1 %1, label %2, label %36
; <label>:r2:                                     ; preds = %r0
  %r3 = fpext float %eps to double
  %r4 = fmul double 2.500000e-01, %r3 
  %r5 = add nsw i32 %wet_j_kp1, %wet_j_km1 
  %r6 = add nsw i32 %r5, %wet_jp1_k 
  %r7 = add nsw i32 %r6, %wet_jm1_k 
  %r8 = sitofp i32 %r7 to double
  %r9 = fmul double %r4, %r8 
  %r10 = fsub double 1.000000e+00, %r9 
  %r11 = fpext float %etan_j_k to double
  %r12 = fmul double %r10, %r11 
  %r13 = fptrunc double %r12 to float
  %r14 = fpext float %eps to double
  %r15 = fmul double 2.500000e-01, %r14 
  %r16 = sitofp i32 %wet_j_kp1 to float
  %r17 = fmul float %r16, %etan_j_kp1 
  %r18 = sitofp i32 %wet_j_km1 to float
  %r19 = fmul float %r18, %etan_j_km1 
  %r20 = fadd float %r17, %r19 
  %r21 = fpext float %r20 to double
  %r22 = fmul double %r15, %r21 
  %r23 = fptrunc double %r22 to float
  %r24 = fpext float %eps to double
  %r25 = fmul double 2.500000e-01, %r24 
  %r26 = sitofp i32 %wet_jp1_k to float
  %r27 = fmul float %r26, %etan_jp1_k 
  %r28 = sitofp i32 %wet_jm1_k to float
  %r29 = fmul float %r28, %etan_jm1_k 
  %r30 = fadd float %r27, %r29 
  %r31 = fpext float %r30 to double
  %r32 = fmul double %r25, %r31 
  %r33 = fptrunc double %r32 to float
  %r34 = fadd float %r13, %r23 
  %r35 = fadd float %r34, %r33 
;  store float %35, float* %eta_j_k, align 4

;  br label %37
; <label>:r36:                                     ; preds = %r0
;  store float %etan_j_k, float* %eta_j_k, align 4

;  br label %37
; <label>:r37:                                     ; preds = %r36, %r2
  %eta_j_k_store = select i1 %r1, float %r35, float %etan_j_k 
  store float %eta_j_k_store, float* %eta_j_k
  %r38 = load float, float* %eta_j_k, align 4 
  %r39 = fmul float 1.000000e+00, %r38 
  %r40 = fmul float 0x3E112E0BE0000000, %etan_avg 
  %r41 = fadd float %r39, %r40 
  store float %r41, float* %eta_j_k, align 4
  ret void
}
