define void @shapiro_reduce_19(float %etan_j_k, float* %etan_avg) {
  %1 = load float, float* %etan_avg, align 4 
  %2 = fdiv float %etan_j_k, 2.500000e+05 
  %3 = fadd float %1, %2 
  store float %3, float* %etan_avg, align 4
  ret void
}
