define void @dyn_map_39(float %dt, float %g, float %eta_j_k, float %eta_j_kp1, float %eta_jp1_k, float %dx, float %dy, float %u_j_k, float* %du_j_k, i32 %wet_j_k, i32 %wet_j_kp1, i32 %wet_jp1_k, float* %duu, float %v_j_k, float* %dv_j_k, float* %un_j_k, float* %un_j_km1, float %h_j_k, float %h_j_km1, float %h_j_kp1, float %h_jm1_k, float %h_jp1_k, float* %vn_j_k, float* %vn_jm1_k, float* %etan_j_k) {
  %1 = fsub float -0.000000e+00, %dt 
  %2 = fmul float %1, %g 
  %3 = fsub float %eta_j_kp1, %eta_j_k 
  %4 = fmul float %2, %3 
  %5 = fdiv float %4, %dx 
  store float %5, float* %du_j_k, align 4
  %6 = fsub float -0.000000e+00, %dt 
  %7 = fmul float %6, %g 
  %8 = fsub float %eta_jp1_k, %eta_j_k 
  %9 = fmul float %7, %8 
  %10 = fdiv float %9, %dy 
  store float %10, float* %dv_j_k, align 4
  store float 0.000000e+00, float* %un_j_k, align 4
  %11 = load float, float* %du_j_k, align 4 
  store float %11, float* %duu, align 4
  %12 = icmp eq i32 %wet_j_k, 1 
  br i1 %12, label %13, label %23

; <label>:13:                                     ; preds = %0
  %14 = icmp eq i32 %wet_j_kp1, 1 
  br i1 %14, label %19, label %15

; <label>:15:                                     ; preds = %13
  %16 = load float, float* %duu, align 4 
  %17 = fpext float %16 to double
  %18 = fcmp ogt double %17, 0.000000e+00 
  br i1 %18, label %19, label %22

; <label>:19:                                     ; preds = %15, %13
  %20 = load float, float* %duu, align 4 
  %21 = fadd float %u_j_k, %20 
  store float %21, float* %un_j_k, align 4
  br label %22

; <label>:22:                                     ; preds = %19, %15
  br label %33

; <label>:23:                                     ; preds = %0
  %24 = icmp eq i32 %wet_j_kp1, 1 
  br i1 %24, label %25, label %32

; <label>:25:                                     ; preds = %23
  %26 = load float, float* %duu, align 4 
  %27 = fpext float %26 to double
  %28 = fcmp olt double %27, 0.000000e+00 
  br i1 %28, label %29, label %32

; <label>:29:                                     ; preds = %25
  %30 = load float, float* %duu, align 4 
  %31 = fadd float %u_j_k, %30 
  store float %31, float* %un_j_k, align 4
  br label %32

; <label>:32:                                     ; preds = %29, %25, %23
  br label %33

; <label>:33:                                     ; preds = %32, %22
  %34 = load float, float* %dv_j_k, align 4 
  store float 0.000000e+00, float* %vn_j_k, align 4
  %35 = icmp eq i32 %wet_j_k, 1 
  br i1 %35, label %36, label %45

; <label>:36:                                     ; preds = %33
  %37 = icmp eq i32 %wet_jp1_k, 1 
  br i1 %37, label %42, label %38

; <label>:38:                                     ; preds = %36
  %39 = load float, float* %dv_j_k, align 4 
  %40 = fpext float %39 to double
  %41 = fcmp ogt double %40, 0.000000e+00 
  br i1 %41, label %42, label %44

; <label>:42:                                     ; preds = %38, %36
  %43 = fadd float %v_j_k, %34 
  store float %43, float* %vn_j_k, align 4
  br label %44

; <label>:44:                                     ; preds = %42, %38
  br label %54

; <label>:45:                                     ; preds = %33
  %46 = icmp eq i32 %wet_jp1_k, 1 
  br i1 %46, label %47, label %53

; <label>:47:                                     ; preds = %45
  %48 = load float, float* %dv_j_k, align 4 
  %49 = fpext float %48 to double
  %50 = fcmp olt double %49, 0.000000e+00 
  br i1 %50, label %51, label %53

; <label>:51:                                     ; preds = %47
  %52 = fadd float %v_j_k, %34 
  store float %52, float* %vn_j_k, align 4
  br label %53

; <label>:53:                                     ; preds = %51, %47, %45
  br label %54

; <label>:54:                                     ; preds = %53, %44
  %55 = load float, float* %un_j_k, align 4 
  %56 = load float, float* %un_j_k, align 4 
  %57 = fpext float %56 to double
  %58 = call double @llvm.fabs.f64(double %57)
  %59 = fptrunc double %58 to float
  %60 = fadd float %55, %59 
  %61 = fpext float %60 to double
  %62 = fmul double 5.000000e-01, %61 
  %63 = fpext float %h_j_k to double
  %64 = fmul double %62, %63 
  %65 = fptrunc double %64 to float
  %66 = load float, float* %un_j_k, align 4 
  %67 = load float, float* %un_j_k, align 4 
  %68 = fpext float %67 to double
  %69 = call double @llvm.fabs.f64(double %68)
  %70 = fptrunc double %69 to float
  %71 = fsub float %66, %70 
  %72 = fpext float %71 to double
  %73 = fmul double 5.000000e-01, %72 
  %74 = fpext float %h_j_kp1 to double
  %75 = fmul double %73, %74 
  %76 = fptrunc double %75 to float
  %77 = fadd float %65, %76 
  %78 = load float, float* %un_j_km1, align 4 
  %79 = load float, float* %un_j_km1, align 4 
  %80 = fpext float %79 to double
  %81 = call double @llvm.fabs.f64(double %80)
  %82 = fptrunc double %81 to float
  %83 = fadd float %78, %82 
  %84 = fpext float %83 to double
  %85 = fmul double 5.000000e-01, %84 
  %86 = fpext float %h_j_km1 to double
  %87 = fmul double %85, %86 
  %88 = fptrunc double %87 to float
  %89 = load float, float* %un_j_km1, align 4 
  %90 = load float, float* %un_j_km1, align 4 
  %91 = fpext float %90 to double
  %92 = call double @llvm.fabs.f64(double %91)
  %93 = fptrunc double %92 to float
  %94 = fsub float %89, %93 
  %95 = fpext float %94 to double
  %96 = fmul double 5.000000e-01, %95 
  %97 = fpext float %h_j_k to double
  %98 = fmul double %96, %97 
  %99 = fptrunc double %98 to float
  %100 = fadd float %88, %99 
  %101 = load float, float* %vn_j_k, align 4 
  %102 = load float, float* %vn_j_k, align 4 
  %103 = fpext float %102 to double
  %104 = call double @llvm.fabs.f64(double %103)
  %105 = fptrunc double %104 to float
  %106 = fadd float %101, %105 
  %107 = fpext float %106 to double
  %108 = fmul double 5.000000e-01, %107 
  %109 = fpext float %h_j_k to double
  %110 = fmul double %108, %109 
  %111 = fptrunc double %110 to float
  %112 = load float, float* %vn_j_k, align 4 
  %113 = load float, float* %vn_j_k, align 4 
  %114 = fpext float %113 to double
  %115 = call double @llvm.fabs.f64(double %114)
  %116 = fptrunc double %115 to float
  %117 = fsub float %112, %116 
  %118 = fpext float %117 to double
  %119 = fmul double 5.000000e-01, %118 
  %120 = fpext float %h_jp1_k to double
  %121 = fmul double %119, %120 
  %122 = fptrunc double %121 to float
  %123 = fadd float %111, %122 
  %124 = load float, float* %vn_jm1_k, align 4 
  %125 = load float, float* %vn_jm1_k, align 4 
  %126 = fpext float %125 to double
  %127 = call double @llvm.fabs.f64(double %126)
  %128 = fptrunc double %127 to float
  %129 = fadd float %124, %128 
  %130 = fpext float %129 to double
  %131 = fmul double 5.000000e-01, %130 
  %132 = fpext float %h_jm1_k to double
  %133 = fmul double %131, %132 
  %134 = fptrunc double %133 to float
  %135 = load float, float* %vn_jm1_k, align 4 
  %136 = load float, float* %vn_jm1_k, align 4 
  %137 = fpext float %136 to double
  %138 = call double @llvm.fabs.f64(double %137)
  %139 = fptrunc double %138 to float
  %140 = fsub float %135, %139 
  %141 = fpext float %140 to double
  %142 = fmul double 5.000000e-01, %141 
  %143 = fpext float %h_j_k to double
  %144 = fmul double %142, %143 
  %145 = fptrunc double %144 to float
  %146 = fadd float %134, %145 
  %147 = fsub float %77, %100 
  %148 = fmul float %dt, %147 
  %149 = fdiv float %148, %dx 
  %150 = fsub float %eta_j_k, %149 
  %151 = fsub float %123, %146 
  %152 = fmul float %dt, %151 
  %153 = fdiv float %152, %dy 
  %154 = fsub float %150, %153 
  store float %154, float* %etan_j_k, align 4
  ret void
}
declare double @llvm.fabs.f64(double)
