// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on
module func_hdl_top_kernel_A (

  input   clock,
  input   resetn,
  input   ivalid, 
  input   iready,
  output  ovalid, 
  output  oready,
  input   [32:0]  ka_vin0,
  input   [32:0]  ka_vin1,
  output  [32:0]  ka_vout);


//From AOCL documentation::  
//For an RTL module with a fixed latency, the output signals (ovalid and oready) can
//have constant high values, and the input ready signal (iready) can be ignored
  
  //statically synchronized, no handshaking 
  assign ovalid = 1'b1;
  assign oready = 1'b1;

  // ivalid, iready, resetn are ignored
  
  reg areset;
  initial
  begin
    #0 areset = 1'b1;
    #5 areset = 1'b0;
  end  

//if not ivalid, then stall  
wire stall = ~ivalid;  
  
kernelTop_kernel_A kernelTop_kernel_A_i
(
   .clk     (clock)
  ,.rst   	(areset)
  ,.stall   (stall)
  ,.ka_vin0 (ka_vin0)
  ,.ka_vin1 (ka_vin1)
  ,.ka_vout (ka_vout)
);
  
endmodule
