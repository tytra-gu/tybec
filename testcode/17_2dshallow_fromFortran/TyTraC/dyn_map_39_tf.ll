define void @dyn_map_39(float %dt, float %g, float %eta_j_k, float %eta_j_kp1, float %eta_jp1_k, float %dx, float %dy, float %u_j_k, float* %du_j_k, i32 %wet_j_k, i32 %wet_j_kp1, i32 %wet_jp1_k, float* %duu, float %v_j_k, float* %dv_j_k, float* %un_j_k, float* %un_j_km1, float %h_j_k, float %h_j_km1, float %h_j_kp1, float %h_jm1_k, float %h_jp1_k, float* %vn_j_k, float* %vn_jm1_k, float* %etan_j_k) {
  %r1 = fsub float -0.000000e+00, %dt 
  %r2 = fmul float %r1, %g 
  %r3 = fsub float %eta_j_kp1, %eta_j_k 
  %r4 = fmul float %r2, %r3 
  %r5 = fdiv float %r4, %dx 
  store float %r5, float* %du_j_k, align 4
  %r6 = fsub float -0.000000e+00, %dt 
  %r7 = fmul float %r6, %g 
  %r8 = fsub float %eta_jp1_k, %eta_j_k 
  %r9 = fmul float %r7, %r8 
  %r10 = fdiv float %r9, %dy 
  store float %r10, float* %dv_j_k, align 4
;  store float 0.000000e+00, float* %un_j_k, align 4
  %r11 = load float, float* %du_j_k, align 4 
  store float %r11, float* %duu, align 4
  %r12 = icmp eq i32 %wet_j_k, 1 

;  br i1 %12, label %13, label %23
; <label>:r13:                                     ; preds = %r0
  %r14 = icmp eq i32 %wet_j_kp1, 1 

;  br i1 %14, label %19, label %15
; <label>:r15:                                     ; preds = %r13
  %r16 = load float, float* %duu, align 4 
  %r17 = fpext float %r16 to double
  %r18 = fcmp ogt double %r17, 0.000000e+00 

;  br i1 %18, label %19, label %22
; <label>:r19:                                     ; preds = %r15, %r13
  %r20 = load float, float* %duu, align 4 
  %r21 = fadd float %u_j_k, %r20 
;  store float %21, float* %un_j_k, align 4

;  br label %22
; <label>:r22:                                     ; preds = %r19, %r15

;  br label %33
; <label>:r23:                                     ; preds = %r0
  %r24 = icmp eq i32 %wet_j_kp1, 1 

;  br i1 %24, label %25, label %32
; <label>:r25:                                     ; preds = %r23
  %r26 = load float, float* %duu, align 4 
  %r27 = fpext float %r26 to double
  %r28 = fcmp olt double %r27, 0.000000e+00 

;  br i1 %28, label %29, label %32
; <label>:r29:                                     ; preds = %r25
  %r30 = load float, float* %duu, align 4 
  %r31 = fadd float %u_j_k, %r30 
;  store float %31, float* %un_j_k, align 4

;  br label %32
; <label>:r32:                                     ; preds = %r29, %r25, %r23

;  br label %33
; <label>:r33:                                     ; preds = %r32, %r22
  %and_12_14_1 = and i1 %r12, %r14 
  %not_14_2 = xor i1 %r14, true 
  %and_12_not_14_2_2 = and i1 %r12, %not_14_2 
  %and_and_12_not_14_2_2_18_2 = and i1 %and_12_not_14_2_2, %r18 
  %or_and_12_14_1_and_and_12_not_14_2_2_18_2_2 = or i1 %and_12_14_1, %and_and_12_not_14_2_2_18_2 
  %prev_un_j_k_0 = select i1 %or_and_12_14_1_and_and_12_not_14_2_2_18_2_2, float %r21, float %r31 
  store float %prev_un_j_k_0, float* %un_j_k
  %not_14_1 = xor i1 %r14, true 
  %not_18_1 = xor i1 %r18, true 
  %and_12_not_14_1_1 = and i1 %r12, %not_14_1 
  %and_and_12_not_14_1_1_not_18_1_1 = and i1 %and_12_not_14_1_1, %not_18_1 
  %not_12_2 = xor i1 %r12, true 
  %not_28_2 = xor i1 %r28, true 
  %and_not_12_2_24_2 = and i1 %not_12_2, %r24 
  %and_and_not_12_2_24_2_not_28_2_2 = and i1 %and_not_12_2_24_2, %not_28_2 
  %not_12_3 = xor i1 %r12, true 
  %not_24_3 = xor i1 %r24, true 
  %and_not_12_3_not_24_3_3 = and i1 %not_12_3, %not_24_3 
  %or_and_and_12_not_14_1_1_not_18_1_1_and_and_not_12_2_24_2_not_28_2_2_3 = or i1 %and_and_12_not_14_1_1_not_18_1_1, %and_and_not_12_2_24_2_not_28_2_2 
  %or_or_and_and_12_not_14_1_1_not_18_1_1_and_and_not_12_2_24_2_not_28_2_2_3_and_not_12_3_not_24_3_3_3 = or i1 %or_and_and_12_not_14_1_1_not_18_1_1_and_and_not_12_2_24_2_not_28_2_2_3, %and_not_12_3_not_24_3_3 
  %un_j_k_store = select i1 %or_or_and_and_12_not_14_1_1_not_18_1_1_and_and_not_12_2_24_2_not_28_2_2_3_and_not_12_3_not_24_3_3_3, float 0.000000e+00, float %prev_un_j_k_0 
  store float %un_j_k_store, float* %un_j_k
  %r34 = load float, float* %dv_j_k, align 4 
;  store float 0.000000e+00, float* %vn_j_k, align 4
  %r35 = icmp eq i32 %wet_j_k, 1 

;  br i1 %35, label %36, label %45
; <label>:r36:                                     ; preds = %r33
  %r37 = icmp eq i32 %wet_jp1_k, 1 

;  br i1 %37, label %42, label %38
; <label>:r38:                                     ; preds = %r36
  %r39 = load float, float* %dv_j_k, align 4 
  %r40 = fpext float %r39 to double
  %r41 = fcmp ogt double %r40, 0.000000e+00 

;  br i1 %41, label %42, label %44
; <label>:r42:                                     ; preds = %r38, %r36
  %r43 = fadd float %v_j_k, %r34 
;  store float %43, float* %vn_j_k, align 4

;  br label %44
; <label>:r44:                                     ; preds = %r42, %r38

;  br label %54
; <label>:r45:                                     ; preds = %r33
  %r46 = icmp eq i32 %wet_jp1_k, 1 

;  br i1 %46, label %47, label %53
; <label>:r47:                                     ; preds = %r45
  %r48 = load float, float* %dv_j_k, align 4 
  %r49 = fpext float %r48 to double
  %r50 = fcmp olt double %r49, 0.000000e+00 

;  br i1 %50, label %51, label %53
; <label>:r51:                                     ; preds = %r47
  %r52 = fadd float %v_j_k, %r34 
;  store float %52, float* %vn_j_k, align 4

;  br label %53
; <label>:r53:                                     ; preds = %r51, %r47, %r45

;  br label %54
; <label>:r54:                                     ; preds = %r53, %r44
  %and_35_37_1 = and i1 %r35, %r37 
  %not_37_2 = xor i1 %r37, true 
  %and_35_not_37_2_2 = and i1 %r35, %not_37_2 
  %and_and_35_not_37_2_2_41_2 = and i1 %and_35_not_37_2_2, %r41 
  %or_and_35_37_1_and_and_35_not_37_2_2_41_2_2 = or i1 %and_35_37_1, %and_and_35_not_37_2_2_41_2 
  %prev_vn_j_k_0 = select i1 %or_and_35_37_1_and_and_35_not_37_2_2_41_2_2, float %r43, float %r52 
  store float %prev_vn_j_k_0, float* %vn_j_k
  %not_37_1 = xor i1 %r37, true 
  %not_41_1 = xor i1 %r41, true 
  %and_35_not_37_1_1 = and i1 %r35, %not_37_1 
  %and_and_35_not_37_1_1_not_41_1_1 = and i1 %and_35_not_37_1_1, %not_41_1 
  %not_35_2 = xor i1 %r35, true 
  %not_50_2 = xor i1 %r50, true 
  %and_not_35_2_46_2 = and i1 %not_35_2, %r46 
  %and_and_not_35_2_46_2_not_50_2_2 = and i1 %and_not_35_2_46_2, %not_50_2 
  %not_35_3 = xor i1 %r35, true 
  %not_46_3 = xor i1 %r46, true 
  %and_not_35_3_not_46_3_3 = and i1 %not_35_3, %not_46_3 
  %or_and_and_35_not_37_1_1_not_41_1_1_and_and_not_35_2_46_2_not_50_2_2_3 = or i1 %and_and_35_not_37_1_1_not_41_1_1, %and_and_not_35_2_46_2_not_50_2_2 
  %or_or_and_and_35_not_37_1_1_not_41_1_1_and_and_not_35_2_46_2_not_50_2_2_3_and_not_35_3_not_46_3_3_3 = or i1 %or_and_and_35_not_37_1_1_not_41_1_1_and_and_not_35_2_46_2_not_50_2_2_3, %and_not_35_3_not_46_3_3 
  %vn_j_k_store = select i1 %or_or_and_and_35_not_37_1_1_not_41_1_1_and_and_not_35_2_46_2_not_50_2_2_3_and_not_35_3_not_46_3_3_3, float 0.000000e+00, float %prev_vn_j_k_0 
  store float %vn_j_k_store, float* %vn_j_k
  %r55 = load float, float* %un_j_k, align 4 
  %r56 = load float, float* %un_j_k, align 4 
  %r57 = fpext float %r56 to double
  %r58 = call double @llvm.fabs.f64(double %r57)
  %r59 = fptrunc double %r58 to float
  %r60 = fadd float %r55, %r59 
  %r61 = fpext float %r60 to double
  %r62 = fmul double 5.000000e-01, %r61 
  %r63 = fpext float %h_j_k to double
  %r64 = fmul double %r62, %r63 
  %r65 = fptrunc double %r64 to float
  %r66 = load float, float* %un_j_k, align 4 
  %r67 = load float, float* %un_j_k, align 4 
  %r68 = fpext float %r67 to double
  %r69 = call double @llvm.fabs.f64(double %r68)
  %r70 = fptrunc double %r69 to float
  %r71 = fsub float %r66, %r70 
  %r72 = fpext float %r71 to double
  %r73 = fmul double 5.000000e-01, %r72 
  %r74 = fpext float %h_j_kp1 to double
  %r75 = fmul double %r73, %r74 
  %r76 = fptrunc double %r75 to float
  %r77 = fadd float %r65, %r76 
  %r78 = load float, float* %un_j_km1, align 4 
  %r79 = load float, float* %un_j_km1, align 4 
  %r80 = fpext float %r79 to double
  %r81 = call double @llvm.fabs.f64(double %r80)
  %r82 = fptrunc double %r81 to float
  %r83 = fadd float %r78, %r82 
  %r84 = fpext float %r83 to double
  %r85 = fmul double 5.000000e-01, %r84 
  %r86 = fpext float %h_j_km1 to double
  %r87 = fmul double %r85, %r86 
  %r88 = fptrunc double %r87 to float
  %r89 = load float, float* %un_j_km1, align 4 
  %r90 = load float, float* %un_j_km1, align 4 
  %r91 = fpext float %r90 to double
  %r92 = call double @llvm.fabs.f64(double %r91)
  %r93 = fptrunc double %r92 to float
  %r94 = fsub float %r89, %r93 
  %r95 = fpext float %r94 to double
  %r96 = fmul double 5.000000e-01, %r95 
  %r97 = fpext float %h_j_k to double
  %r98 = fmul double %r96, %r97 
  %r99 = fptrunc double %r98 to float
  %r100 = fadd float %r88, %r99 
  %r101 = load float, float* %vn_j_k, align 4 
  %r102 = load float, float* %vn_j_k, align 4 
  %r103 = fpext float %r102 to double
  %r104 = call double @llvm.fabs.f64(double %r103)
  %r105 = fptrunc double %r104 to float
  %r106 = fadd float %r101, %r105 
  %r107 = fpext float %r106 to double
  %r108 = fmul double 5.000000e-01, %r107 
  %r109 = fpext float %h_j_k to double
  %r110 = fmul double %r108, %r109 
  %r111 = fptrunc double %r110 to float
  %r112 = load float, float* %vn_j_k, align 4 
  %r113 = load float, float* %vn_j_k, align 4 
  %r114 = fpext float %r113 to double
  %r115 = call double @llvm.fabs.f64(double %r114)
  %r116 = fptrunc double %r115 to float
  %r117 = fsub float %r112, %r116 
  %r118 = fpext float %r117 to double
  %r119 = fmul double 5.000000e-01, %r118 
  %r120 = fpext float %h_jp1_k to double
  %r121 = fmul double %r119, %r120 
  %r122 = fptrunc double %r121 to float
  %r123 = fadd float %r111, %r122 
  %r124 = load float, float* %vn_jm1_k, align 4 
  %r125 = load float, float* %vn_jm1_k, align 4 
  %r126 = fpext float %r125 to double
  %r127 = call double @llvm.fabs.f64(double %r126)
  %r128 = fptrunc double %r127 to float
  %r129 = fadd float %r124, %r128 
  %r130 = fpext float %r129 to double
  %r131 = fmul double 5.000000e-01, %r130 
  %r132 = fpext float %h_jm1_k to double
  %r133 = fmul double %r131, %r132 
  %r134 = fptrunc double %r133 to float
  %r135 = load float, float* %vn_jm1_k, align 4 
  %r136 = load float, float* %vn_jm1_k, align 4 
  %r137 = fpext float %r136 to double
  %r138 = call double @llvm.fabs.f64(double %r137)
  %r139 = fptrunc double %r138 to float
  %r140 = fsub float %r135, %r139 
  %r141 = fpext float %r140 to double
  %r142 = fmul double 5.000000e-01, %r141 
  %r143 = fpext float %h_j_k to double
  %r144 = fmul double %r142, %r143 
  %r145 = fptrunc double %r144 to float
  %r146 = fadd float %r134, %r145 
  %r147 = fsub float %r77, %r100 
  %r148 = fmul float %dt, %r147 
  %r149 = fdiv float %r148, %dx 
  %r150 = fsub float %eta_j_k, %r149 
  %r151 = fsub float %r123, %r146 
  %r152 = fmul float %dt, %r151 
  %r153 = fdiv float %r152, %dy 
  %r154 = fsub float %r150, %r153 
  store float %r154, float* %etan_j_k, align 4
  ret void
}
declare double @llvm.fabs.f64(double)
