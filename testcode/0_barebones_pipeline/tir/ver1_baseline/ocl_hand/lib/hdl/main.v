// =============================================================================
// Company              : Unversity of Glasgow, Comuting Science
// Template Author      :        Syed Waqar Nabi
//
// Project Name         : TyTra
//
// Target Devices       : Stratix V 
//
// Generated Design Name: untitled
// Generated Module Name: main 
// Generator Version    : R17.0
// Generator TimeStamp  : Sun Aug  6 17:23:22 2017
// 
// Dependencies         : <dependencies>
//
// 
// =============================================================================

// =============================================================================
// General Description
// -----------------------------------------------------------------------------
// A generic module template for leaf map nodes for use by Tytra Back-End Compile
// (TyBEC)
//
// ============================================================================= 

module main
#(  
   parameter DATAW     = 32
)

(
// =============================================================================
// ** Ports 
// =============================================================================
    input clk   
  , input rst   	
  , input stall
  
  , input [DATAW-1:0] vin1_stream_load
  , input [DATAW-1:0] vin0_stream_load
  , output [DATAW-1:0] vout_stream_store
);



main_kernelTop 
main_kernelTop_i (
  .clk   (clk)
, .rst   (rst)
, .stall (stall)
, .kt_vout  (vout_stream_store)
, .kt_vin0  (vin0_stream_load)
, .kt_vin1  (vin1_stream_load)
);


endmodule 