define void @shapiro_reduce_19(float %etan_j_k, float* %etan_avg) {
  %r1 = load float, float* %etan_avg, align 4 
  %r2 = fdiv float %etan_j_k, 2.500000e+05 
  %r3 = fadd float %r1, %r2 
  store float %r3, float* %etan_avg, align 4
  ret void
}
