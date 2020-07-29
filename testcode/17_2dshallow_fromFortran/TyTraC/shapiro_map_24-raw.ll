; ModuleID = '../TyTraC/./shapiro_map_24_tmp.bc'
source_filename = "../TyTraC/./shapiro_map_24.c"
target datalayout = "e-m:o-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.14.0"

; Function Attrs: noinline nounwind ssp uwtable
define void @shapiro_map_24(i32, i32, i32, i32, i32, float, float, float, float, float, float, float*, float) #0 {
  %14 = icmp eq i32 %0, 1
  br i1 %14, label %15, label %49

; <label>:15:                                     ; preds = %13
  %16 = fpext float %5 to double
  %17 = fmul double 2.500000e-01, %16
  %18 = add nsw i32 %2, %1
  %19 = add nsw i32 %18, %4
  %20 = add nsw i32 %19, %3
  %21 = sitofp i32 %20 to double
  %22 = fmul double %17, %21
  %23 = fsub double 1.000000e+00, %22
  %24 = fpext float %6 to double
  %25 = fmul double %23, %24
  %26 = fptrunc double %25 to float
  %27 = fpext float %5 to double
  %28 = fmul double 2.500000e-01, %27
  %29 = sitofp i32 %2 to float
  %30 = fmul float %29, %8
  %31 = sitofp i32 %1 to float
  %32 = fmul float %31, %7
  %33 = fadd float %30, %32
  %34 = fpext float %33 to double
  %35 = fmul double %28, %34
  %36 = fptrunc double %35 to float
  %37 = fpext float %5 to double
  %38 = fmul double 2.500000e-01, %37
  %39 = sitofp i32 %4 to float
  %40 = fmul float %39, %10
  %41 = sitofp i32 %3 to float
  %42 = fmul float %41, %9
  %43 = fadd float %40, %42
  %44 = fpext float %43 to double
  %45 = fmul double %38, %44
  %46 = fptrunc double %45 to float
  %47 = fadd float %26, %36
  %48 = fadd float %47, %46
  store float %48, float* %11, align 4
  br label %50

; <label>:49:                                     ; preds = %13
  store float %6, float* %11, align 4
  br label %50

; <label>:50:                                     ; preds = %49, %15
  %51 = load float, float* %11, align 4
  %52 = fmul float 1.000000e+00, %51
  %53 = fmul float 0x3E112E0BE0000000, %12
  %54 = fadd float %52, %53
  store float %54, float* %11, align 4
  ret void
}

attributes #0 = { noinline nounwind ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.module.flags = !{!0, !1, !2}
!llvm.ident = !{!3}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 10, i32 14]}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{i32 7, !"PIC Level", i32 2}
!3 = !{!"clang version 8.0.0 (tags/RELEASE_800/final)"}
