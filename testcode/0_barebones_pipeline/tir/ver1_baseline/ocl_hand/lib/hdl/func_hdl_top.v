// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on
module func_hdl_top (

  input   clock,
  input   resetn,
  input   ivalid, 
  input   iready,
  output  ovalid, 
  output  oready,
  input   [32:0]  datain_vin0_stream_load,
  input   [32:0]  datain_vin1_stream_load,
  output  [32:0]  dataout_vout_stream_store);


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
  
main main_i
(
   .clk               (clock)
  ,.rst   	          (areset)
  ,.stall             (stall)
  ,.vin0_stream_load  (datain_vin0_stream_load)
  ,.vin1_stream_load  (datain_vin1_stream_load)
  ,.vout_stream_store (dataout_vout_stream_store)
);
  
endmodule
