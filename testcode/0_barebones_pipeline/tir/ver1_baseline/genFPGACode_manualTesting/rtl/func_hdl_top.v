// synopsys translate_off
//`timescale 1 ps / 1 ps


//utilities
`include "util.v"

// synopsys translate_on
module func_hdl_top
#(  
   parameter DATAW     = 32
)
(
   input   clock 
  ,input   resetn
  ,input   ivalid 
  ,input   iready
  ,output  ovalid 
  ,output  oready
  
 , input [DATAW-1:0] vin0_stream_load
 , input [DATAW-1:0] vin1_stream_load
 , output [DATAW-1:0] vout_stream_store
);

 
  //statically synchronized, no handshaking 
  assign ovalid = 1'b1;
  assign oready = 1'b1;

  // ivalid, iready, resetn are ignored
  
  //ignore resetn and create my own?
  //---from altera's example
//  reg rst_n;
//  initial
//  begin
//    #0 rst_n = 1'b0;
//    #5 rst_n = 1'b1;
//  end
  
wire rst = !resetn;
wire ovalidDut; 
  
main main_i(
   .clk               (clock)
  ,.rst               (rst)
  ,.stall             (!ivalid)
  ,.ovalid            (ovalidDut)
, .vin1_stream_load  (vin1_stream_load)
, .vin0_stream_load  (vin0_stream_load)
, .vout_stream_store  (vout_stream_store)

);
  
endmodule
