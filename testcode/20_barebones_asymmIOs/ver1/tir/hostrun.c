  auto cstart = std::chrono::high_resolution_clock::now();        //<----------TIMER START  
  //!**** start of iteration loop ****
  for (int n =0; n < ntot; n++) {
  //!*********************************
    for (int i=0; i<DATA_SIZE; i++) {
      vout0[i] = (vin0[i] + vin1[i])*(vin0[i] + vin1[i])*32;
      vout1[i] = (vin0[i] + vin1[i])*(vin0[i] + vin1[i])*32;
    }//for i
  }//for n 
  auto cend = std::chrono::high_resolution_clock::now();          //<----------TIMER END
  std::chrono::duration<double> cpu_time_used = cend - cstart;
