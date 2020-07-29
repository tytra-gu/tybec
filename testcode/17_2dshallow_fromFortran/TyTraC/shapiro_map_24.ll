define void @shapiro_map_24(i32 %wet_j_k, i32 %wet_j_km1, i32 %wet_j_kp1, i32 %wet_jm1_k, i32 %wet_jp1_k, float %eps, float %etan_j_k, float %etan_j_km1, float %etan_j_kp1, float %etan_jm1_k, float %etan_jp1_k, float* %eta_j_k, float %etan_avg) {
  %1 = icmp eq i32 %wet_j_k, 1 
  br i1 %1, label %2, label %36

; <label>:2:                                     ; preds = %0
  %3 = fpext float %eps to double
  %4 = fmul double 2.500000e-01, %3 
  %5 = add nsw i32 %wet_j_kp1, %wet_j_km1 
  %6 = add nsw i32 %5, %wet_jp1_k 
  %7 = add nsw i32 %6, %wet_jm1_k 
  %8 = sitofp i32 %7 to double
  %9 = fmul double %4, %8 
  %10 = fsub double 1.000000e+00, %9 
  %11 = fpext float %etan_j_k to double
  %12 = fmul double %10, %11 
  %13 = fptrunc double %12 to float
  %14 = fpext float %eps to double
  %15 = fmul double 2.500000e-01, %14 
  %16 = sitofp i32 %wet_j_kp1 to float
  %17 = fmul float %16, %etan_j_kp1 
  %18 = sitofp i32 %wet_j_km1 to float
  %19 = fmul float %18, %etan_j_km1 
  %20 = fadd float %17, %19 
  %21 = fpext float %20 to double
  %22 = fmul double %15, %21 
  %23 = fptrunc double %22 to float
  %24 = fpext float %eps to double
  %25 = fmul double 2.500000e-01, %24 
  %26 = sitofp i32 %wet_jp1_k to float
  %27 = fmul float %26, %etan_jp1_k 
  %28 = sitofp i32 %wet_jm1_k to float
  %29 = fmul float %28, %etan_jm1_k 
  %30 = fadd float %27, %29 
  %31 = fpext float %30 to double
  %32 = fmul double %25, %31 
  %33 = fptrunc double %32 to float
  %34 = fadd float %13, %23 
  %35 = fadd float %34, %33 
  store float %35, float* %eta_j_k, align 4
  br label %37

; <label>:36:                                     ; preds = %0
  store float %etan_j_k, float* %eta_j_k, align 4
  br label %37

; <label>:37:                                     ; preds = %36, %2
  %38 = load float, float* %eta_j_k, align 4 
  %39 = fmul float 1.000000e+00, %38 
  %40 = fmul float 0x3E112E0BE0000000, %etan_avg 
  %41 = fadd float %39, %40 
  store float %41, float* %eta_j_k, align 4
  ret void
}
