; ModuleID = '../TyTraC/./dyn_map_39_tmp.bc'
source_filename = "../TyTraC/./dyn_map_39.c"
target datalayout = "e-m:o-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.14.0"

; Function Attrs: noinline nounwind ssp uwtable
define void @dyn_map_39(float, float, float, float, float, float, float, float, float*, i32, i32, i32, float*, float, float*, float*, float*, float, float, float, float, float, float*, float*, float*) #0 {
  %26 = fsub float -0.000000e+00, %0
  %27 = fmul float %26, %1
  %28 = fsub float %3, %2
  %29 = fmul float %27, %28
  %30 = fdiv float %29, %5
  store float %30, float* %8, align 4
  %31 = fsub float -0.000000e+00, %0
  %32 = fmul float %31, %1
  %33 = fsub float %4, %2
  %34 = fmul float %32, %33
  %35 = fdiv float %34, %6
  store float %35, float* %14, align 4
  store float 0.000000e+00, float* %15, align 4
  %36 = load float, float* %8, align 4
  store float %36, float* %12, align 4
  %37 = icmp eq i32 %9, 1
  br i1 %37, label %38, label %48

; <label>:38:                                     ; preds = %25
  %39 = icmp eq i32 %10, 1
  br i1 %39, label %44, label %40

; <label>:40:                                     ; preds = %38
  %41 = load float, float* %12, align 4
  %42 = fpext float %41 to double
  %43 = fcmp ogt double %42, 0.000000e+00
  br i1 %43, label %44, label %47

; <label>:44:                                     ; preds = %40, %38
  %45 = load float, float* %12, align 4
  %46 = fadd float %7, %45
  store float %46, float* %15, align 4
  br label %47

; <label>:47:                                     ; preds = %44, %40
  br label %58

; <label>:48:                                     ; preds = %25
  %49 = icmp eq i32 %10, 1
  br i1 %49, label %50, label %57

; <label>:50:                                     ; preds = %48
  %51 = load float, float* %12, align 4
  %52 = fpext float %51 to double
  %53 = fcmp olt double %52, 0.000000e+00
  br i1 %53, label %54, label %57

; <label>:54:                                     ; preds = %50
  %55 = load float, float* %12, align 4
  %56 = fadd float %7, %55
  store float %56, float* %15, align 4
  br label %57

; <label>:57:                                     ; preds = %54, %50, %48
  br label %58

; <label>:58:                                     ; preds = %57, %47
  %59 = load float, float* %14, align 4
  store float 0.000000e+00, float* %22, align 4
  %60 = icmp eq i32 %9, 1
  br i1 %60, label %61, label %70

; <label>:61:                                     ; preds = %58
  %62 = icmp eq i32 %11, 1
  br i1 %62, label %67, label %63

; <label>:63:                                     ; preds = %61
  %64 = load float, float* %14, align 4
  %65 = fpext float %64 to double
  %66 = fcmp ogt double %65, 0.000000e+00
  br i1 %66, label %67, label %69

; <label>:67:                                     ; preds = %63, %61
  %68 = fadd float %13, %59
  store float %68, float* %22, align 4
  br label %69

; <label>:69:                                     ; preds = %67, %63
  br label %79

; <label>:70:                                     ; preds = %58
  %71 = icmp eq i32 %11, 1
  br i1 %71, label %72, label %78

; <label>:72:                                     ; preds = %70
  %73 = load float, float* %14, align 4
  %74 = fpext float %73 to double
  %75 = fcmp olt double %74, 0.000000e+00
  br i1 %75, label %76, label %78

; <label>:76:                                     ; preds = %72
  %77 = fadd float %13, %59
  store float %77, float* %22, align 4
  br label %78

; <label>:78:                                     ; preds = %76, %72, %70
  br label %79

; <label>:79:                                     ; preds = %78, %69
  %80 = load float, float* %15, align 4
  %81 = load float, float* %15, align 4
  %82 = fpext float %81 to double
  %83 = call double @llvm.fabs.f64(double %82)
  %84 = fptrunc double %83 to float
  %85 = fadd float %80, %84
  %86 = fpext float %85 to double
  %87 = fmul double 5.000000e-01, %86
  %88 = fpext float %17 to double
  %89 = fmul double %87, %88
  %90 = fptrunc double %89 to float
  %91 = load float, float* %15, align 4
  %92 = load float, float* %15, align 4
  %93 = fpext float %92 to double
  %94 = call double @llvm.fabs.f64(double %93)
  %95 = fptrunc double %94 to float
  %96 = fsub float %91, %95
  %97 = fpext float %96 to double
  %98 = fmul double 5.000000e-01, %97
  %99 = fpext float %19 to double
  %100 = fmul double %98, %99
  %101 = fptrunc double %100 to float
  %102 = fadd float %90, %101
  %103 = load float, float* %16, align 4
  %104 = load float, float* %16, align 4
  %105 = fpext float %104 to double
  %106 = call double @llvm.fabs.f64(double %105)
  %107 = fptrunc double %106 to float
  %108 = fadd float %103, %107
  %109 = fpext float %108 to double
  %110 = fmul double 5.000000e-01, %109
  %111 = fpext float %18 to double
  %112 = fmul double %110, %111
  %113 = fptrunc double %112 to float
  %114 = load float, float* %16, align 4
  %115 = load float, float* %16, align 4
  %116 = fpext float %115 to double
  %117 = call double @llvm.fabs.f64(double %116)
  %118 = fptrunc double %117 to float
  %119 = fsub float %114, %118
  %120 = fpext float %119 to double
  %121 = fmul double 5.000000e-01, %120
  %122 = fpext float %17 to double
  %123 = fmul double %121, %122
  %124 = fptrunc double %123 to float
  %125 = fadd float %113, %124
  %126 = load float, float* %22, align 4
  %127 = load float, float* %22, align 4
  %128 = fpext float %127 to double
  %129 = call double @llvm.fabs.f64(double %128)
  %130 = fptrunc double %129 to float
  %131 = fadd float %126, %130
  %132 = fpext float %131 to double
  %133 = fmul double 5.000000e-01, %132
  %134 = fpext float %17 to double
  %135 = fmul double %133, %134
  %136 = fptrunc double %135 to float
  %137 = load float, float* %22, align 4
  %138 = load float, float* %22, align 4
  %139 = fpext float %138 to double
  %140 = call double @llvm.fabs.f64(double %139)
  %141 = fptrunc double %140 to float
  %142 = fsub float %137, %141
  %143 = fpext float %142 to double
  %144 = fmul double 5.000000e-01, %143
  %145 = fpext float %21 to double
  %146 = fmul double %144, %145
  %147 = fptrunc double %146 to float
  %148 = fadd float %136, %147
  %149 = load float, float* %23, align 4
  %150 = load float, float* %23, align 4
  %151 = fpext float %150 to double
  %152 = call double @llvm.fabs.f64(double %151)
  %153 = fptrunc double %152 to float
  %154 = fadd float %149, %153
  %155 = fpext float %154 to double
  %156 = fmul double 5.000000e-01, %155
  %157 = fpext float %20 to double
  %158 = fmul double %156, %157
  %159 = fptrunc double %158 to float
  %160 = load float, float* %23, align 4
  %161 = load float, float* %23, align 4
  %162 = fpext float %161 to double
  %163 = call double @llvm.fabs.f64(double %162)
  %164 = fptrunc double %163 to float
  %165 = fsub float %160, %164
  %166 = fpext float %165 to double
  %167 = fmul double 5.000000e-01, %166
  %168 = fpext float %17 to double
  %169 = fmul double %167, %168
  %170 = fptrunc double %169 to float
  %171 = fadd float %159, %170
  %172 = fsub float %102, %125
  %173 = fmul float %0, %172
  %174 = fdiv float %173, %5
  %175 = fsub float %2, %174
  %176 = fsub float %148, %171
  %177 = fmul float %0, %176
  %178 = fdiv float %177, %6
  %179 = fsub float %175, %178
  store float %179, float* %24, align 4
  ret void
}

; Function Attrs: nounwind readnone speculatable
declare double @llvm.fabs.f64(double) #1

attributes #0 = { noinline nounwind ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readnone speculatable }

!llvm.module.flags = !{!0, !1, !2}
!llvm.ident = !{!3}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 10, i32 14]}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{i32 7, !"PIC Level", i32 2}
!3 = !{!"clang version 8.0.0 (tags/RELEASE_800/final)"}
